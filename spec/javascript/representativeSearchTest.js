/* global HDO*/

(function (H) {
    buster.testCase('Representative Search', {
        "should build search data from model": function () {
            var dataFromServer = [{
                "created_at":"2012-06-30T10:12:37Z",
                "date_of_birth":"1967-02-20T23:00:00Z",
                "date_of_death":null,
                "district_id":1,
                "external_id":"MAAA",
                "first_name":"Marianne",
                "id":110,
                "last_name":"Aasen",
                "party_id":1,
                "updated_at":"2012-06-30T10:12:37Z"
            }];

            var result = H.representativeSearch.parse(dataFromServer);
            assert.equals(result, [{
                id: "maaa",
                name: "Marianne Aasen"
            }]);
        }

    });
}(HDO));
