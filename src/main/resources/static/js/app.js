document.documentElement.classList.add("js-enabled");

// Doi anh chinh khi khach chon mot anh nho trong gallery.
document.querySelectorAll(".shop-thumbnails button").forEach((button) => {
    button.addEventListener("click", () => {
        const mainImage = document.querySelector("[data-product-main-image]");
        if (!mainImage) return;

        mainImage.src = button.dataset.imageSrc;
        mainImage.alt = button.dataset.imageAlt || mainImage.alt;
        document.querySelectorAll(".shop-thumbnails button").forEach((item) => {
            item.classList.toggle("is-active", item === button);
        });
        const counter = document.querySelector(".shop-image-counter");
        if (counter) {
            counter.textContent = `${String(button.dataset.imageIndex).padStart(2, "0")} / ${document.querySelectorAll(".shop-thumbnails button").length}`;
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
    });
});

