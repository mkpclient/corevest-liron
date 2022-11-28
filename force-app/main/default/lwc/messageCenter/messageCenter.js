import { LightningElement, api, track } from "lwc";
import getCommentsById from "@salesforce/apex/MessageCenterController.getCommentsById";
import getAllComments from "@salesforce/apex/MessageCenterController.getAllComments";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";
import saveComment from "@salesforce/apex/MessageCenterController.saveComment";

export default class MessageCenter extends LightningElement {
  @api recordId = "006Z000000IJCuJIAX";
  @api objectApiName;

  comments = [];

  selectedComments = [];

  commentSubject = "";

  selectedCommentId;

  // selectedCommentId = "";
  // page = 1;
  // pageSizez = 20;

  // get comments() {
  //   // const comments = this.comments;
  //   const comments = [];

  //   //const paginationStart = (page - 1) * pageSize; //2
  //   //const paginationEnd = page * pageSize; //3

  //   return this.comments.slice(paginationStart, paginationEnd);
  // }

  // get selectedCommentId() {
  //   return this.selectedComments.length > 0 ? this.selectedComments[0].id : "";
  // }

  get selectedCommentInfo() {
    return this.selectedComments.length > 0 ? this.selectedComments[0] : {};
  }

  connectedCallback() {
    console.log("connected callback");
    this.fetchComments();
  }

  fetchComments() {
    getAllComments({ recordId: this.recordId })
      .then((comments) => {
        console.log(comments);

        comments.forEach((comment) => {
          if (comment.propertyId) {
            comment.title = "Property Related" + " " + comment.subject;
          } else if (comment.loanId) {
            comment.title = "Loan/Deal Related " + comment.subject;
          } else if (comment.applicationId) {
            comment.title = "Application Related" + " " + comment.subject;
          } else if (comment.itemId) {
            comment.title = "Checklist Related " + comment.subject;
          } else if (comment.documentId) {
            comment.title = "Document Related " + comment.subject;
          }
        });

        this.comments = comments;

        if (comments.length > 0) {
          this.selectedCommentId = comments[0].id;
          //this.fetchCommentAndChildren(comments[0].id);
        }
      })
      .catch((error) => {
        console.log("comments error");
        console.log(error);
      });
  }

  fetchCommentAndChildren(commentId) {
    getCommentsById({ commentId: commentId })
      .then((comments) => {
        console.log(comments);
        // comments.forEach((comment) => {
        //   // if(!comment.profileImg){
        //   // }
        //   let url = "/lightning/r/";
        //   let urlName = "";
        //   if (comment.propertyId) {
        //     url += `Property__c/${comment.propertyId}/view`;
        //     urlName = comment.propertyName;
        //   } else if (comment.loanId) {
        //     url += `Opportunity/${comment.loanId}/view`;
        //     urlName = comment.loanName;
        //   } else if (comment.applicationId) {
        //     url += `Application__c/${comment.applicationId}/view`;
        //     urlName = comment.applicationName;
        //   } else if (comment.documentId) {
        //     url += `Deal_Document__c/${comment.documentId}/view`;
        //     urlName = comment.documentName;
        //   }

        //   comment.url = url;
        //   comment.urlName = urlName;
        // });
        // this.selectedCommentInfo = comments[0];

        comments.forEach((comment) => {
          if (comment.propertyId) {
            comment.title = "Property Related" + " " + comment.subject;
          } else if (comment.loanId) {
            comment.title = "Loan/Deal Related " + comment.subject;
          } else if (comment.applicationId) {
            comment.title = "Application Related" + " " + comment.subject;
          } else if (comment.documentId) {
            comment.title = "Document Related " + comment.subject;
          }
        });
        console.log(comments[0].title);
        this.commentSubject = comments[0].title;
        console.log(this.commentSubject);
        this.selectedComments = comments;
        //this.template.querySelector("lightning-textarea").value = "";
      })
      .catch((error) => {
        console.log("single comment error");
        console.log(error);
      });
  }

  createComment() {
    console.log("create comment");
    const body = this.template.querySelector("lightning-textarea").value;

    console.log(body);

    if (body) {
      const comments = this.selectedComments;
      const lastComment = this.selectedComments[comments.length - 1];
      const comment = {
        sobjectType: "Comment__c",
        Comment__c: lastComment.id,
        Property__c: lastComment.propertyId,
        Application__c: lastComment.applicationId,
        Deal__c: lastComment.loanId,
        Deal_Document__c: lastComment.documentId,
        Body__c: body
      };
      console.log(comment);
      saveComment({ request: JSON.stringify(comment) }).then((result) => {
        this.template.querySelector("lightning-textarea").value = "";
        this.fetchCommentAndChildren(comments[0].id);
      });
    }
  }

  handleCommentSelect(event) {
    console.log("handleSelect");
    //console.log(event.target.getAttribute("data-title"));
    //this.title = event.target.getAttribute("data-title");
    if (event.detail.name) {
      this.fetchCommentAndChildren(event.detail.name);
    }
  }
}