document.documentElement.classList.add("js-enabled");

// Doi anh chinh khi khach chon mot anh nho trong gallery.
const imageButtons = [...document.querySelectorAll(".shop-thumbnails button")];
imageButtons.forEach((button) => {
    button.addEventListener("click", () => {
        const mainImage = document.querySelector("[data-product-main-image]");
        if (!mainImage) return;

        mainImage.src = button.dataset.imageSrc;
        mainImage.alt = button.dataset.imageAlt || mainImage.alt;
        imageButtons.forEach((item) => {
            item.classList.toggle("is-active", item === button);
        });
        const counter = document.querySelector(".shop-image-counter");
        if (counter) {
            const visible = imageButtons.filter((item) => !item.hidden);
            counter.textContent = `${String(visible.indexOf(button) + 1).padStart(2, "0")} / ${visible.length}`;
        }
    });
});

// Hien gia va ton kho cua bien the duoc chon ma khong tao thao tac mua hang gia.
document.querySelectorAll(".shop-size-option").forEach((button) => {
    button.addEventListener("click", () => {
        document.querySelectorAll(".shop-size-option").forEach((item) => {
            item.setAttribute("aria-pressed", String(item === button));
        });
        const feedback = document.querySelector("[data-variant-feedback]");
        if (feedback) {
            feedback.textContent = `${button.dataset.variantSku} · ${button.dataset.variantPrice} ₫ · Còn ${button.dataset.variantStock} đôi`;
        }
        // Chi hien anh cua bien the duoc chon; anh chinh la anh primary cua bien the do.
        const matching = imageButtons.filter((image) => image.dataset.variantId === button.dataset.variantId);
        imageButtons.forEach((image) => { image.hidden = !matching.includes(image); });
        const primary = matching.find((image) => image.dataset.imagePrimary === "true") || matching[0];
        if (primary) {
            primary.click();
        } else {
            const mainImage = document.querySelector("[data-product-main-image]");
            if (mainImage) mainImage.src = "/images/demo/shoe-placeholder.svg";
            const counter = document.querySelector(".shop-image-counter");
            if (counter) counter.textContent = "00 / 00";
        }
    });
});

// Dong bo Color Picker va ma HEX trong form tao/sua mau.
function initColorPicker() {
    const colorPicker = document.getElementById("colorPicker");
    const hexInput = document.getElementById("hexCodeInput");
    const previewBox = document.getElementById("colorPickerPreview");
    if (!colorPicker || !hexInput) return;

    const isValidHex = (val) => /^#[0-9A-Fa-f]{6}$/.test(val);

    const updatePreview = (hex) => {
        if (!previewBox) return;
        if (hex && isValidHex(hex)) {
            previewBox.style.backgroundColor = hex;
            previewBox.classList.remove("no-color");
            previewBox.title = `Mã màu: ${hex}`;
        } else {
            previewBox.style.backgroundColor = "transparent";
            previewBox.classList.add("no-color");
            previewBox.title = "Chưa có mã màu";
        }
    };

    // Khi chon tren bang mau -> cap nhat ma HEX va preview
    colorPicker.addEventListener("input", () => {
        const hex = colorPicker.value.toUpperCase();
        hexInput.value = hex;
        updatePreview(hex);
    });

    // Khi go tay ma HEX -> dong bo nguoc lai bang mau
    hexInput.addEventListener("input", () => {
        let val = hexInput.value.trim();
        if (val && !val.startsWith("#") && /^[0-9A-Fa-f]{6}$/.test(val)) {
            val = "#" + val;
            hexInput.value = val;
        }
        if (isValidHex(val)) {
            colorPicker.value = val;
            updatePreview(val);
        } else if (val === "") {
            updatePreview("");
        }
    });

    // Cac nut mau goi y chon nhanh
    document.querySelectorAll(".color-preset-btn").forEach((btn) => {
        btn.addEventListener("click", () => {
            const hex = btn.dataset.hex;
            if (hex) {
                hexInput.value = hex;
                colorPicker.value = hex;
                updatePreview(hex);
            }
        });
    });

    // Khoi tao trang thai ban dau
    const initialHex = hexInput.value.trim();
    if (isValidHex(initialHex)) {
        colorPicker.value = initialHex;
        updatePreview(initialHex);
    } else {
        updatePreview("");
    }
}

// Hien o nho demo mau sac khi nguoi dung chon mau cho bien the san pham.
function initColorSelectDemo() {
    document.querySelectorAll(".color-select-wrapper").forEach((wrapper) => {
        const select = wrapper.querySelector("select");
        const demoBox = wrapper.querySelector(".color-demo-box");
        if (!select || !demoBox) return;

        const updateDemo = () => {
            const selectedOption = select.options[select.selectedIndex];
            const hex = selectedOption ? selectedOption.dataset.hex : null;
            if (hex && /^#[0-9A-Fa-f]{6}$/.test(hex)) {
                demoBox.style.backgroundColor = hex;
                demoBox.classList.remove("no-color");
                demoBox.title = `Mã màu: ${hex}`;
            } else {
                demoBox.style.backgroundColor = "transparent";
                demoBox.classList.add("no-color");
                demoBox.title = "Chưa có mã màu";
            }
        };

        select.addEventListener("change", updateDemo);
        updateDemo();
    });
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => {
        initColorPicker();
        initColorSelectDemo();
    });
} else {
    initColorPicker();
    initColorSelectDemo();
}

