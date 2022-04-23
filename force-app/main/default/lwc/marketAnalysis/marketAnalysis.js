import { LightningElement } from 'lwc';

export default class MarketAnalysis extends LightningElement {
    mapMarkers = [
        {
            location: {
                Street: 'Orange County',
                // City: 'New York',
                // State: 'NY',
                Latitude: '33.6474',
                Longitude: '-117.9207'
            },

            title: 'Orange County',
            description:
                'A grand setting for one of the greatest collections of art, from ancient to contemporary.',
        },
        {
            location: {
                Street: 'Santa Rosa',
                // City: 'New York',
                // State: 'NY',
                Latitude: '38.257',
                Longitude: '-122.4597'
            },

            title: 'Santa Rosa',
            description:
                'A grand setting for one of the greatest collections of art, from ancient to contemporary.',
        },
        {
            location: {
                Street: 'Grand Junction',
                // City: 'New York',
                // State: 'NY',
                Latitude: '39.0875',
                Longitude: '-108.3488'
            },

            title: 'Grand Junction',
            description:
                'A grand setting for one of the greatest collections of art, from ancient to contemporary.',
        },
    ];
    // zoomLevel = 15;
    listView = 'visible';
}