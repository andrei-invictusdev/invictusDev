/**
 * Created by oltea on 01/11/2024.
 */

@IsTest
public with sharing class WeatherStatusControllerTest {

    @TestSetup static void testSetup() {
        Account newAccount = new Account(Name = 'Test Account', BillingCountry = 'Romania', BillingState = 'Bucuresti', BillingCity = 'Bucharest');
        insert newAccount;
    }

    @IsTest static void testWithNoResponse() {
        Account newAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            System.assert(WeatherStatusController.getWeatherData(newAccount.Id) == null);
        Test.stopTest();
    }

    @IsTest static void testWithResponse() {
        Account newAccount = [SELECT Id FROM Account LIMIT 1];
        GeocodingMock mockResp = new GeocodingMock();
        Test.setMock(HttpCalloutMock.class, mockResp);

        Test.startTest();
            System.assert(WeatherStatusController.getWeatherData(newAccount.Id) != null);
        Test.stopTest();
    }

    @IsTest static void testWithGeocodingMock() {
        GeocodingMock mockResp = new GeocodingMock();
        Test.setMock(HttpCalloutMock.class, mockResp);

        Test.startTest();
            System.assert(WeatherStatusController.getGeocodeLocation('Bucharest', 'Bucharest', 'Romania') != null);
        Test.stopTest();
    }

    @IsTest static void testWithWeatherMock() {
        WeatherApiMock mockResp = new WeatherApiMock();
        Test.setMock(HttpCalloutMock.class, mockResp);

        Test.startTest();
            System.assert(WeatherStatusController.getWeatherInfo('52.52', '13.419998') != null);
        Test.stopTest();
    }

}