/*global cull, HDO */

(function (H, cull) {
  buster.testCase('Representative Search', {
    setUp: function () {
      this.dataFromServer = [{
        "created_at":"2012-06-30T10:12:37Z",
        "date_of_birth":"1967-02-20T23:00:00Z",
        "date_of_death":null,
        "district_id":1,
        "external_id":"MAAA",
        "first_name":"Marianne",
        "id":110,
        "last_name":"Aasen",
        "slug": "maaa",
        "party_id":1,
        "updated_at":"2012-06-30T10:12:37Z"
      }];

      this.searcher = H.representativeSearch.create({
        data: this.dataFromServer
      });
    },

    "should build search data from model": function () {
      assert.equals(this.searcher.mappedData, {
        "Marianne Aasen": "maaa"
      });
    },

    "should return source data": function () {
      assert.equals(this.searcher.getSource(), ["Marianne Aasen"]);
    },

    "should redirect on update": function () {
      var listener = this.spy();
      H.redirect = listener;

      this.searcher.updater("Marianne Aasen");
      assert.calledOnceWith(listener, "/representatives/maaa");
    }

  });
}(HDO, cull));
