/**
 * Created by oltea on 01/11/2024.
 */

global class GeocodingMock implements HttpCalloutMock {

    private static final String RESPONSE_STRING = '{"results":[{"id":683506,"name":"Bucharest","latitude":44.43225,"longitude":26.10626,"elevation":83.0,"feature_code":"PPLC","country_code":"RO","admin1_id":683504,"admin2_id":8335003,"admin3_id":11055044,"timezone":"Europe/Bucharest","population":1877155,"country_id":798549,"country":"Romania","admin1":"București","admin2":"Municipiul Bucureşti","admin3":"Sector 3"},{"id":11500082,"name":"Bucharest Clinceni","latitude":44.35892,"longitude":25.93184,"elevation":75.0,"feature_code":"AIRF","country_code":"RO","admin1_id":865518,"timezone":"Europe/Bucharest","country_id":798549,"country":"Romania","admin1":"Ilfov"},{"id":6299701,"name":"Bucharest Băneasa Aurel Vlaicu International Airport","latitude":44.50319,"longitude":26.10211,"elevation":90.0,"feature_code":"AIRP","country_code":"RO","admin1_id":683504,"admin2_id":8335003,"admin3_id":11055041,"timezone":"Europe/Bucharest","country_id":798549,"country":"Romania","admin1":"București","admin2":"Municipiul Bucureşti","admin3":"Sector 1"}],"generationtime_ms":1.2429953}';

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(RESPONSE_STRING);

        return res;
    }

}