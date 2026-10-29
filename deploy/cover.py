#!/usr/bin/env python3
"""HTTP 200 on / for PaaS health; raw TCP tunnel for WebSocket path to xray."""
import asyncio, os, sys

PUBLIC = int(os.environ.get("PORT", "8080"))
XRAY = 8081
WSPATH = os.environ.get("WSPATH", "/ws")
if not WSPATH.startswith("/"):
    WSPATH = "/" + WSPATH

async def pipe(a, b):
    try:
        while True:
            data = await a.read(65536)
            if not data:
                break
            b.write(data)
            await b.drain()
    except Exception:
        pass
    try:
        b.close()
    except Exception:
        pass

async def handle(reader, writer):
    try:
        req = await asyncio.wait_for(reader.readuntil(b"\r\n\r\n"), timeout=30)
    except Exception:
        writer.close()
        try:
            await writer.wait_closed()
        except Exception:
            pass
        return
    head = req.split(b"\r\n", 1)[0].decode("latin1", "replace")
    parts = head.split(" ")
    method = parts[0] if parts else ""
    target = parts[1] if len(parts) > 1 else "/"
    path = target.split("?", 1)[0]
    upgrade = b"\nupgrade: websocket" in req.lower() or b"\r\nupgrade: websocket" in req.lower()
    if path == WSPATH or path.startswith(WSPATH + "/"):
        try:
            xr, xw = await asyncio.open_connection("127.0.0.1", XRAY)
        except Exception:
            writer.write(b"HTTP/1.1 502 Bad Gateway\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
            await writer.drain()
            writer.close()
            return
        xw.write(req)
        await xw.drain()
        await asyncio.gather(pipe(reader, xw), pipe(xr, writer))
        return
    # health / everything else
    body = b"ok\n"
    writer.write(
        b"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: "
        + str(len(body)).encode()
        + b"\r\nConnection: close\r\n\r\n"
        + body
    )
    await writer.drain()
    writer.close()
    try:
        await writer.wait_closed()
    except Exception:
        pass

async def main():
    server = await asyncio.start_server(handle, "0.0.0.0", PUBLIC)
    print(f"cover python public={PUBLIC} xray={XRAY} path={WSPATH}", flush=True)
    async with server:
        await server.serve_forever()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(0)
