import asyncio
import base64
import json
import subprocess
import time
import urllib.request
import websockets
import os

ARTIFACT_DIR = "/home/dian/.gemini/antigravity/brain/72a488db-fcb9-42ab-b0de-e5ad2eb2676d"
WEB_DIR = "/home/dian/palayplan/mobile/build/web"

async def click_at(send, x, y):
    await send("Input.dispatchMouseEvent", {
        "type": "mousePressed",
        "x": x,
        "y": y,
        "button": "left",
        "clickCount": 1
    })
    await send("Input.dispatchMouseEvent", {
        "type": "mouseReleased",
        "x": x,
        "y": y,
        "button": "left",
        "clickCount": 1
    })

async def capture(send, filename):
    res = await send("Page.captureScreenshot", {"format": "png"})
    if "data" in res:
        out_path = os.path.join(ARTIFACT_DIR, filename)
        with open(out_path, "wb") as f:
            f.write(base64.b64decode(res["data"]))
        print(f"Saved {filename}")

async def main():
    # Start web server if not already running
    server_proc = subprocess.Popen(
        ["python3", "-m", "http.server", "8088", "--directory", WEB_DIR],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    time.sleep(1)

    chrome_cmd = [
        "google-chrome",
        "--headless=new",
        "--remote-debugging-port=9222",
        "--no-sandbox",
        "--disable-gpu",
        "--window-size=412,892",
        "--user-data-dir=/tmp/chrome_test_profile_capture",
        "http://localhost:8088/"
    ]
    chrome_proc = subprocess.Popen(chrome_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(2)

    try:
        resp = urllib.request.urlopen("http://localhost:9222/json")
        targets = json.loads(resp.read().decode())
        page_target = next((t for t in targets if t.get("type") == "page"), None)
        if not page_target:
            print("No page target found")
            return

        ws_url = page_target["webSocketDebuggerUrl"]
        print(f"Connecting to CDP: {ws_url}")

        async with websockets.connect(ws_url) as ws:
            msg_id = 1

            async def send(method, params=None):
                nonlocal msg_id
                cmd = {"id": msg_id, "method": method, "params": params or {}}
                msg_id += 1
                await ws.send(json.dumps(cmd))
                while True:
                    res = json.loads(await ws.recv())
                    if res.get("id") == cmd["id"]:
                        return res.get("result", {})

            await send("Page.enable")
            await send("Runtime.enable")

            # Emulate Pixel 7: 412x892
            await send("Emulation.setDeviceMetricsOverride", {
                "width": 412,
                "height": 892,
                "deviceScaleFactor": 2.0,
                "mobile": True
            })

            # 1. Capture Splash Screen
            print("Waiting for splash screen...")
            await asyncio.sleep(1.5)
            await capture(send, "screen_splash.png")

            # 2. Wait for auto-transition to Home Screen (splash timer 2.5s)
            print("Waiting for home screen...")
            await asyncio.sleep(3.5)
            await capture(send, "screen_home.png")

            # 3. Tap Scan Card (Feature card around x=206, y=260 on home)
            print("Navigating to Scan Screen...")
            await click_at(send, 206, 260)
            await asyncio.sleep(1.5)
            await capture(send, "screen_scanner.png")

            # Go back to home
            await click_at(send, 24, 30)
            await asyncio.sleep(1.0)

            # 4. Tap Weather Forecast Tile (around x=206, y=360)
            print("Navigating to Weather Screen...")
            await click_at(send, 206, 360)
            await asyncio.sleep(1.5)
            await capture(send, "screen_weather.png")

            # Go back to home
            await click_at(send, 24, 30)
            await asyncio.sleep(1.0)

            # 5. Tap Cropping Calendar Tile (around x=206, y=440)
            print("Navigating to Calendar Screen...")
            await click_at(send, 206, 440)
            await asyncio.sleep(1.5)
            await capture(send, "screen_calendar.png")

            # Go back to home
            await click_at(send, 24, 30)
            await asyncio.sleep(1.0)

            # 6. Tap Advisories Tile (around x=206, y=520)
            print("Navigating to Advisory Screen...")
            await click_at(send, 206, 520)
            await asyncio.sleep(1.5)
            await capture(send, "screen_advisory.png")

    finally:
        chrome_proc.terminate()
        chrome_proc.wait()
        server_proc.terminate()
        server_proc.wait()

if __name__ == "__main__":
    asyncio.run(main())
