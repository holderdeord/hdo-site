var HDO = HDO || {};

(function (H, $) {
    H.representativeSelector = {
        init: function (opts) {
            var districtSelect, representativeSelect, representatives, selectedRepresentatives;

            districtSelect       = opts.districtSelect;
            representativeSelect = opts.representativeSelect;
            representatives      = districtSelect.data('representatives');

            function useRepresentativesFrom(district) {
                representativeSelect.html('<option/>');

                if (district === '') {
                    selectedRepresentatives = representatives;
                } else {
                    selectedRepresentatives = $(representatives).filter(function () {
                        return district === this.district;
                    });
                }

                $.each(selectedRepresentatives, function () {
                    var opt = $('<option />').val(this.slug).text(this.name).attr('disabled', this.opted_out);
                    representativeSelect.append(opt);
                });

                representativeSelect.trigger('liszt:updated'); // chosen
            }

            districtSelect.change(function () {
                useRepresentativesFrom($(this).val());

                if (opts.selectedRepresentative !== '') {
                    representativeSelect.val(opts.selectedRepresentative).change();
                }
            });

            if (opts.selectedDistrict !== '') {
                districtSelect.val(opts.selectedDistrict).change();
            }

            representativeSelect.chosen({search_contains: true});
            districtSelect.chosen({disable_search: true});
        }
    };
}(HDO, window.jQuery));
