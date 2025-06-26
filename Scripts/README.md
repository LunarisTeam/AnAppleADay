# ⚙️ Dependencies Build & Packaging Guide

Welcome! This folder automates everything you need to \*\*build, re‑build, and package the third‑party native code that your *visionOS* Xcode project links against—most notably a custom‑configured, statically‑linked build of [VTK (Visualization Toolkit)](https://vtk.org/).

> **TL;DR**
> **Run `./setup-dependencies.sh` and grab the generated frameworks.**
> The script figures out the rest.

---

## 🗺️ Folder Contents

| File                            | Purpose                                                                                                                                                                                                                                                       |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`setup-dependencies.sh`**     | **Entry point.** Performs sanity checks (macOS & Xcode versions, Homebrew, CMake) and decides—via the `TARGET` env var—whether you are building for the **visionOS simulator** or a real **Apple Vision Pro device**. It then calls the helper scripts below. |
| **`setup-vtk-compiletools.sh`** | Installs & configures the *compile tools* (SDK, platform toolchain, sysroot, and CMake toolchain file) that allow a **cross build**: compiling on macOS while emitting binaries for visionOS.                                                                 |
| **`setup-vtk.sh`**              | Invoked by the main script; drives CMake to produce a **statically‑linked, visionOS‑ready VTK** by enabling only the modules Apple Vision Pro supports and turning off everything else.                                                                       |

> **Heads‑up 📑**
> These scripts were crafted with care. **Do not edit them unless you *really* know what you are doing.** We cannot guarantee support for custom modifications.

---

## 🚀 Quick Start

```bash
cd Scripts/                # ← this directory
chmod +x setup-dependencies.sh  # first time only
./setup-dependencies.sh         # builds for whatever TARGET is set to
```

**Choosing your target**
The default build target is detected automatically, but you can override it:

```bash
# Build for an attached Vision Pro device
TARGET=xros ./setup-dependencies.sh

# Build for the visionOS simulator
TARGET=xrsimulator ./setup-dependencies.sh
```

### What happens next?

1. **Environment check** – verifies Xcode, visionOS SDK, Homebrew packages.
2. **Toolchain prep** – `setup-vtk-compiletools.sh` installs the visionOS‑specific clang, sysroot & a CMake toolchain file.
3. **VTK configure + build** – `setup-vtk.sh` passes a *long* set of `-DVTK_*` flags to CMake, disabling unsupported modules (OpenGL, CUDA, etc.) and requesting a **static** build (`BUILD_SHARED_LIBS=OFF`).
4. **Artifacts** land in `build/output/<target>/`, ready for packaging.

> **❗ CMake hiccup**
> On some machines the first CMake configure step inexplicably fails. **Just rerun the script**—the second pass always succeeds. Investigation continues. 🙃

---

## 🛠️ Cross Building 101 (Why do we need compile tools?)

A **cross build** compiles code on one platform (your Mac) that will run on a different platform (visionOS). Apple ships the visionOS SDK, but we still need:

* a clang/ld that targets `arm64e-apple-visionos` or `xros64-apple-visionos-simulator`,
* the correct sysroot (headers & libs),
* a CMake toolchain file so CMake picks the right compiler, linker, and ABI.

`setup-vtk-compiletools.sh` automates those steps so CMake never gets confused.

---

## 📦 Bundling VTK for Xcode

We ship a **pre‑built `VisualizationToolkit.xcframework` (visionOS 2.2+)** containing slices for both **device** and **simulator**. You’ll find it under `Frameworks/`. Using it is the fastest route:

1. **Decompress** `VisualizationToolkit.xcframework.tar.zst` into *your* Xcode project’s *Frameworks* folder.
2. **Drag‑and‑drop** `VTK-visionOS.xcframework` into *your* Xcode project’s *Frameworks, Libraries & Embedded Content* section.
3. Set the framework to **“Embed & Sign”.**
4. Clean → Build. Done.

### When should I rebuild VTK myself?

* You changed **CMake flags** (e.g. enabling extra VTK modules).
* You need to support a **different visionOS SDK** or an Xcode beta.

In that case, run the scripts for **both** targets:

```bash
TARGET=xrsimulator ./setup-dependencies.sh
TARGET=xros     ./setup-dependencies.sh
```

Then create a fresh `.xcframework`:

```bash
xcodebuild -create-xcframework \
  -library build/output/simulator/libvtk.a \
  -headers build/output/simulator/include \
  -library build/output/device/libvtk.a \
  -headers build/output/device/include \
  -output VTK-visionOS.xcframework
```

(You can of course automate this in your own script.)

> **Direct linking instead of a framework**
> Nothing stops you from adding each static library (`libvtkCommonCore.a`, `libvtkRenderingCore.a`, …) to Xcode individually—handy when iterating on CMake flags and you don’t want to re‑package every time.

---

## 🧹 Cleaning Up

```bash
./setup-dependencies.sh clean   # removes build/ & temp toolchains
```

---

## ❓ FAQ

| Question                                            | Answer                                                                                                          |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| *“Which macOS/Xcode/CMake versions are supported?”* | Tested on macOS 14.5 & Xcode 16.0 (visionOS SDK 2.2). CMake ≥ 3.29 via Homebrew.                                |
| *“Why static linking?”*                             | Fewer runtime dependencies, simpler embedding in .xcframework, and reduced dynamic loader overhead on visionOS. |
| *“Can I swap clang versions?”*                      | Yes—edit `COMPILER_VERSION` at the top of `setup-vtk-compiletools.sh`, but you’re on your own.                  |

---

## 📜 License & Attribution

These helper scripts are released under the same license as the parent project. VTK itself is BSD‑licensed (© Kitware, Inc.). See `LICENSE` files for details.

Happy building, and enjoy crafting immersive experiences on Apple Vision Pro! 🍎🛠️
