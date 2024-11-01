/**
 * Created by oltea on 01/11/2024.
 */

public with sharing class WeatherStatusController {

    private static final String FIXED_SEPARATOR = '///';

    @AuraEnabled(cacheable=false)
    public static List<WeatherDataWrapper> getWeatherData(String recordId) {
        if (String.isNotBlank(recordId)) {
            List<Account> queryResult = [
                    SELECT BillingCity, BillingCountry, BillingState
                    FROM Account
                    WHERE Id = :recordId
            ];

            if (!queryResult.isEmpty()) {
                Account currentAccount = queryResult[0];

                if (String.isNotBlank(currentAccount.BillingCity) && String.isNotBlank(currentAccount.BillingState) && String.isNotBlank(currentAccount.BillingCountry)) {
                    String geocodes = getGeocodeLocation(currentAccount.BillingCity, currentAccount.BillingState, currentAccount.BillingCountry);

                    if (String.isNotBlank(geocodes)) {
                        WeatherApiResponse weatherApiResponse = getWeatherInfo(geocodes.split(FIXED_SEPARATOR)[0], geocodes.split(FIXED_SEPARATOR)[1]);

                        if (weatherApiResponse != null) {
                            List<WeatherDataWrapper> wrappers = new List<WeatherDataWrapper>();

                            if (weatherApiResponse.hourly != null && weatherApiResponse.hourly.times.size() == weatherApiResponse.hourly.temperature_2m.size()) {
                                Integer size = weatherApiResponse.hourly.times.size();

                                for (Integer i = 0; i < size; i++) {
                                    wrappers.add(new WeatherDataWrapper(i, weatherApiResponse.hourly.times[i].replace('T', ' '), String.valueOf(weatherApiResponse.hourly.temperature_2m[i] + ' °C')));
                                }
                            }

                            return wrappers;
                        }
                    }
                }
            }
        }

        return null;
    }

    @TestVisible
    private static String getGeocodeLocation(String city, String state, String country) {
        city = cleanupDirtyChars(city);
        state = cleanupDirtyChars(state);
        country = cleanupDirtyChars(country);

        try {
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            request.setMethod('GET');
            request.setEndpoint('https://geocoding-api.open-meteo.com/v1/search?name=' + city + '&count=10&language=en&format=json');
            HttpResponse response = http.send(request);

            if (response != null && response.getStatusCode() == 200) {
                GeocodingApiResponse apiResult = (GeocodingApiResponse) JSON.deserialize(response.getBody(), GeocodingApiResponse.class);

                if (apiResult != null) {
                    for (GeocodingApiInnerResponse auxInnerResponse : apiResult.results) {

                        if (country.equalsIgnoreCase(cleanupDirtyChars(auxInnerResponse.country)) && state.equalsIgnoreCase(cleanupDirtyChars(auxInnerResponse.admin1))  && city.equalsIgnoreCase(cleanupDirtyChars(auxInnerResponse.name))) {
                            return auxInnerResponse.latitude + FIXED_SEPARATOR + auxInnerResponse.longitude;
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(ex);
        }

        return '';
    }

    @TestVisible
    private static WeatherApiResponse getWeatherInfo(String latitude, String longitude) {
        String tomorrowDate = System.now().addDays(1).format('yyyy-MM-dd').toString();

        try {
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            request.setMethod('GET');
            request.setEndpoint('https://api.open-meteo.com/v1/forecast?latitude=' + latitude + '&longitude=' + longitude + '&hourly=temperature_2m&start_date=' + tomorrowDate + '&end_date=' + tomorrowDate);

            HttpResponse response = http.send(request);

            if (response != null && response.getStatusCode() == 200) {
                return (WeatherApiResponse) JSON.deserialize(response.getBody().replace('time', 'times'), WeatherApiResponse.class);
            }
        } catch (Exception ex) {
            System.debug(ex);
        }

        return null;
    }

    class GeocodingApiResponse {
        public List<GeocodingApiInnerResponse> results { get; set; }
    }

    class GeocodingApiInnerResponse {
        public String name { get; set; }
        public String latitude { get; set; }
        public String longitude { get; set; }
        public String country { get; set; }
        public String admin1 { get; set; }
    }

    @TestVisible
    class WeatherApiResponse {
        public WeatherApiInnerResponse hourly;
    }

    @TestVisible
    class WeatherApiInnerResponse {
        public List<String> times { get; set; }
        public List<Decimal> temperature_2m { get; set; }
    }

    class WeatherDataWrapper {
        @AuraEnabled public Integer id;
        @AuraEnabled public String weatherTime;
        @AuraEnabled public String temperature;

        WeatherDataWrapper(Integer id, String weatherTime, String temperature) {
            this.id = id;
            this.weatherTime = weatherTime;
            this.temperature = temperature;
        }
    }

    private static String cleanupDirtyChars(String dirtyString) {
        if (String.isNotBlank(dirtyString)) {
            dirtyString = dirtyString.replaceAll('ă', 'a');
            dirtyString = dirtyString.replaceAll('â', 'a');
            dirtyString = dirtyString.replaceAll('î', 'i');
            dirtyString = dirtyString.replaceAll('ş', 's');
            dirtyString = dirtyString.replaceAll('ș', 's');
            dirtyString = dirtyString.replaceAll('ţ', 't');
        }

        return dirtyString;
    }

}