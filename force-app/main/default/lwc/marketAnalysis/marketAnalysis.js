import { LightningElement } from 'lwc';

export default class MarketAnalysis extends LightningElement {
    mapMarkers = [
        {
            location: {
                Street: '1000 5th Ave',
                // City: 'New York',
                // State: 'NY',
                Latitude: '40.7831856',
                Longitude: '-73.9675653'
            },

            title: 'Museum of Fine Arts',
            description:
                'A grand setting for one of the greatest collections of art, from ancient to contemporary.',
        },
    ];
    zoomLevel = 15;
    listView = 'visible';
}