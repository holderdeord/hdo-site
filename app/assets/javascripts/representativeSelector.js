var HDO = HDO || {};

(function (H, $) {
  H.representativeSelector = {
    init: function (opts) {
      var districtSelect, representativeSelect, representativeMap;

      districtSelect       = opts.districtSelect;
      representativeSelect = opts.representativeSelect;
      representativeMap    = districtSelect.data('representatives');

      function useRepresentativesFrom(district) {
        representativeSelect.html($('<option/>').text(representativeSelect.data('placeholder')));

        $.each(representativeMap[district], function () {
          representativeSelect.append($("<option />").val(this.slug).text(this.name_with_party));
        });

        representativeSelect.show();
      }

      districtSelect.change(function (e) {
        useRepresentativesFrom($(this).val());

        if (opts.selectedRepresentative !== '') {
          representativeSelect.val(opts.selectedRepresentative).change();
        }
      });

      if (opts.selectedDistrict !== '') {
        districtSelect.val(opts.selectedDistrict).change();
      }
    }
  };
}(HDO, window.jQuery));
