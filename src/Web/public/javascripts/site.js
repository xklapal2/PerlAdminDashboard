
window.addEventListener('load', function () {
    const alertPlaceholder = document.getElementById('alertPlaceholder');
});

function triggerAlert(type, message) {
    showAlert(type, message || defaultMessages[type]);
}

function showAlert(type, message) {
    const alert = document.createElement("div");
    alert.innerHTML = [
        `<div class="alert alert-${type} alert-dismissible" data-bs-theme="dark" >`,
        `   <div>${message}</div>`,
        '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
        '</div>'
    ].join('');

    alertPlaceholder.appendChild(alert);

    let alertTimeout;

    const removeAlert = () => alert.remove();
    alertTimeout = setTimeout(removeAlert, 5000);

    alert.addEventListener("mouseenter", () => {
        clearTimeout(alertTimeout);
    });

    alert.addEventListener("mouseleave", () => {
        alertTimeout = setTimeout(removeAlert, 5000);
    });
}

const defaultMessages = {
    success: "Processed successfully!",
    error: "Ups... something went wrong!",
};