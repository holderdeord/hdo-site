var HDO = HDO || {};

(function (H, $, _) {

    function clearInput() {
        $(this).val("");
    }

    H.representativeSearch = {

        init: function (element, data) {
            var source = this.parse(data);
            // uses lib/bootstrap-typeahead.js, extension to regular bootstrap
            $(element).typeahead({
                source: source,
                itemSelected: function (item, val, text) {
                    document.location = "/representatives/" + val;
                }
            });

            $(element).on("focus", clearInput);
        },

        parse: function (data) {
            return _.map(data, function (obj) {
                return {
                    id: obj.external_id.toLowerCase(),
                    name: [obj.first_name, obj.last_name].join(" ")
                };
            });
        }
    };
}(HDO, $, _));
