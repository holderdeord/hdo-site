var HDO = HDO || {};

(function (H, $) {
  function keyUp(ev) {
    if (ev.target.value === '') {
      $(this.target).hide();
    }
  }

  function search(ev) {
    ev.preventDefault();

    var q, self;

    q = $(ev.target).find("input[type=text]").val();
    self = this;

    $(self.target).html('');

    if (!q.length) {
      return;
    }

    $(self.spinner).show();

    $.ajax({
      url: "/search/all/" + encodeURIComponent(q),
      type: "GET",
      dataType: "html",

      complete: function () {
        $(self.spinner).hide();
        $(self.target).show();
      },

      success: function (html) {
        $(self.target).html(html);
      },

      error: function (xhr, textStatus) {
        $(self.target).html(textStatus);
      }
    });
  }

  HDO.globalSearchWidget = {
    create: function (params) {
      var instance = Object.create(this);
      instance.form = params.form;
      instance.target = params.target;
      instance.spinner = params.spinner;

      return instance;
    },

    init: function () {
      $(this.form).on("keyup", "input[type=text]", keyUp.bind(this));
      $(this.form).on("submit", search.bind(this));
      $(this.form).find("input[type=text]").focus();
    }
  };

}(HDO, jQuery));


