
window.addEventListener('load', function () {
    const alertPlaceholder = document.getElementById('alertPlaceholder');
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
});

function triggerAlert(type, message, millis = 5000, withLoading = false) {
    showAlert(type, message || defaultMessages[type], millis, withLoading);
}

function showAlert(type, message, millis, withLoading) {
    const alert = document.createElement("div");
    alert.innerHTML = [
        `<div class="alert alert-${type} alert-dismissible d-flex align-items-center" data-bs-theme="dark" >`,
        withLoading
            ? `<div class="mx-2 spinner-grow spinner-grow-sm text-${type}" role="status"> <span class="visually-hidden">Loading...</span></div>`
            : ``,
        `   <div>${message}</div>`,
        '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
        '</div>'
    ].join('');

    alertPlaceholder.innerHTML = "";
    alertPlaceholder.appendChild(alert);

    if (millis && millis !== -1) {
        let alertTimeout;

        const removeAlert = () => alert.remove();
        alertTimeout = setTimeout(removeAlert, millis);

        alert.addEventListener("mouseenter", () => {
            clearTimeout(alertTimeout);
        });

        alert.addEventListener("mouseleave", () => {
            alertTimeout = setTimeout(removeAlert, millis);
        });
    }
}

const defaultMessages = {
    success: "Processed successfully!",
    error: "Ups... something went wrong!",
};

// function initWebSocketConnection(wsUrl) {
//     console.log("Connecting to: ", wsUrl);
//     let socket = new WebSocket(wsUrl);

//     socket.onopen = function (event) {
//         console.log('WebSocket connection established');
//     };

//     socket.onmessage = function (event) {
//         console.log('Message from server:', event.data);
//     };

//     socket.onclose = function (event) {
//         console.log('WebSocket connection closed', event);
//         socket.close();
//     };

//     socket.onerror = function (error) {
//         console.error('WebSocket error:', error);
//     };

//     $(window).on('beforeunload', function () {
//         socket.close();
//     });
// }