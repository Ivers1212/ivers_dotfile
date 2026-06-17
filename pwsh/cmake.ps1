# =============================================================================
# cmake.ps1
# CMake / Ninja / embedded build helpers
# =============================================================================

function rmbld {
    Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
}

function cclean {
    rmbld
}

function bld {
    if (Test-Path ".\build") {
        cmake --build .\build -v
    } else {
        Write-Host "build directory not found." -ForegroundColor Yellow
    }
}

function cfg-ninja {
    cmake -S . -B build -G Ninja
}

function gdf103cm {
    param(
        [ValidateSet("HXTAL", "IRC8M")]
        [string]$ClockSrc = "HXTAL"
    )

    Write-Host "GD32 clock source: $ClockSrc"

    rmbld

    cmake -S . -B build -G Ninja `
        -DCMAKE_TOOLCHAIN_FILE="cmake/toolchain_arm-none-eabi-gcc.cmake" `
        -DDEVICE=gd32f103c8t6 `
        "-DGD32_CLOCK_SRC=$ClockSrc" `
        -DGD32_CLOCK_FREQ_HZ=8000000 `
        -DGD32_SYSCLK_HZ=72000000 `
        -DCMAKE_BUILD_TYPE=Debug
}

function gdf103cm_led {
    param(
        [ValidateSet("HXTAL", "IRC8M")]
        [string]$ClockSrc = "HXTAL",

        [Alias("O")]
        [ValidateRange(0, 1000)]
        [int]$Orange = 350,

        [Alias("G")]
        [ValidateRange(0, 1000)]
        [int]$Green = 200,

        [Alias("B")]
        [ValidateRange(0, 1000)]
        [int]$Blue = 1000
    )

    Write-Host "GD32 clock source: $ClockSrc"
    Write-Host "LED Orange max duty: $Orange / 1000"
    Write-Host "LED Green  max duty: $Green / 1000"
    Write-Host "LED Blue   max duty: $Blue / 1000"

    rmbld

    cmake -S . -B build -G Ninja `
        -DCMAKE_TOOLCHAIN_FILE="cmake/toolchain_arm-none-eabi-gcc.cmake" `
        -DDEVICE=gd32f103c8t6 `
        "-DGD32_CLOCK_SRC=$ClockSrc" `
        -DGD32_CLOCK_FREQ_HZ=8000000 `
        -DGD32_SYSCLK_HZ=72000000 `
        "-DMW_LED_COLOR_O_MAX_DUTY_PERMILLE=$Orange" `
        "-DMW_LED_COLOR_G_MAX_DUTY_PERMILLE=$Green" `
        "-DMW_LED_COLOR_B_MAX_DUTY_PERMILLE=$Blue" `
        -DCMAKE_BUILD_TYPE=Debug
}

function stf103cm {
    rmbld

    cmake -S . -B build -G Ninja `
        -DCMAKE_TOOLCHAIN_FILE="cmake/toolchain_arm-none-eabi-gcc.cmake" `
        -DDEVICE=stm32f103c8t6 `
        -DCMAKE_BUILD_TYPE=Debug
}
