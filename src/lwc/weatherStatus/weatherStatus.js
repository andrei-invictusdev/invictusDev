/**
 * Created by oltea on 01/11/2024.
 */

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getWeatherDataApex from '@salesforce/apex/WeatherStatusController.getWeatherData';

const FIELDS = ['Account.BillingCity', 'Account.BillingCountry', 'Account.BillingState'];

const columns = [
    { label: 'Time', fieldName: 'weatherTime', type: 'String' },
    { label: 'Temperature', fieldName: 'temperature', type: 'String' }
];

export default class WeatherStatus extends LightningElement {

    @api recordId;

    @track tableData;
    @track showLoader;
    @track weatherDataWrapper;

    billingCity = '';
    billingCountry = '';
    billingState = '';
    date;
    columns = columns;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        wiredRecord({ error, data }) {
            if (error) {
                this.showToastMessage('Error', 'An error has occurred while loading weather information', 'error');
            } else if (data) {
                if ((this.billingCity != '' && this.billingCity != data.fields.BillingCity.value)
                        || (this.billingCountry != '' && this.billingCountry != data.fields.BillingCountry.value)
                        || (this.billingState != '' && this.billingState != data.fields.BillingState.value)) {
                    this.init();
                } else {
                    this.billingCity = data.fields.BillingCity.value;
                    this.billingCountry = data.fields.BillingCountry.value;
                    this.billingState = data.fields.BillingState.value;
                }
            }
        }

    connectedCallback() {
        this.init();
    }

    init() {
        if (this.recordId != undefined) {
            this.weatherDataWrapper = null
            this.showLoader = true;

            this.date = new Date().setDate(new Date().getDate() + 1);

            getWeatherDataApex({ recordId: this.recordId })
                .then(result => {
                    if (result) {
                        this.weatherDataWrapper = result;
                    }

                    this.showLoader = false;
                })
                .catch(error => {
                    this.showToastMessage('Error', 'An error has occurred while loading weather information', 'error');
                    this.showLoader = false;
                })
        }
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissible'
            })
        )
    }

}