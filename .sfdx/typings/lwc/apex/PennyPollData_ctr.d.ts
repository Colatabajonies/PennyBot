declare module "@salesforce/apex/PennyPollData_ctr.getEngagement" {
  export default function getEngagement(param: {engagementId: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.getListViews" {
  export default function getListViews(): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.getAllEngagements" {
  export default function getAllEngagements(param: {listViewId: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.toggleActivateEngagement" {
  export default function toggleActivateEngagement(param: {engagementId: any, listViewId: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.getActiveEngagement" {
  export default function getActiveEngagement(param: {engagementId: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.getQuestions" {
  export default function getQuestions(param: {engagementId: any, displayALL: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.getPollResults" {
  export default function getPollResults(param: {engagementId: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.getLabels" {
  export default function getLabels(param: {engagementId: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.getPollVotes" {
  export default function getPollVotes(param: {engagementId: any}): Promise<any>;
}
declare module "@salesforce/apex/PennyPollData_ctr.clearData" {
  export default function clearData(): Promise<any>;
}
