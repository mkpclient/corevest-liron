import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitKnacklyOrder from '@salesforce/apex/KnacklyAPI.submitKnacklyOrder';

//export default class SwapRateUpdate extends LightningElement {
export default class KnacklySync extends LightningElement {
    @api recordId;
    isExecuting = false;    
    @api async invoke() {
        if (this.isExecuting) {
            return;
        }  
        console.log('submitKnacklyOrder Execution Start Record id is : ' , this.recordId);
        this.isExecuting = true;
       // await this.sleep(500);
        this.isExecuting = false;
        document.body.style.cursor = 'wait';
        submitKnacklyOrder({opportunityId : this.recordId})
        .then((result) => {
            console.log('result :', result);
            if (result == 'Success')
            {
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Knackly Sync Successful!',
                Varient: 'success'
            });
            this.dispatchEvent(event);
            document.body.style.cursor = '';            
            }
            else
            {
            const event = new ShowToastEvent({
                title: 'Warning!',
                message: 'Failed to call Knackly. Please contact System Adminstrator',
                Varient: 'warning'
            });
            this.dispatchEvent(event);
            document.body.style.cursor = '';             
            } 
        })
        .catch((error) => {
          console.log("Error Calling Knackly");
          console.log(error);
          document.body.style.cursor = '';           
        });
        console.log('Error Calling Knackly Stop');
    } 
}