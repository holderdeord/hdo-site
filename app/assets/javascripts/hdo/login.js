define(["jquery"], function ($) {
  var $status = $("#login-status");

  function loadStatus() {
    $.ajax({
      url: "/home/login_status",
      type: "GET",
      dataType: "html",
      success: function (html) {
        $status.html(html);
      },
      error: function () {
        if (window.console) { console.log(arguments); }
      }
    });
  }

  return {

    status: function () {
      if ($status.size() === 1) {
        loadStatus();
      }
    }
  };
});