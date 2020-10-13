<aura:application implements="force:appHostable,lightning:isUrlAddressable" extends="force:slds">
	<aura:attribute name="engagementId" type="String" />
    <aura:attribute name="displayALL" type="Boolean" default="false" />
    <aura:attribute name="chatZoom" type="String" default="100" />
    <c:PennyMainDisplay refId="{!v.engagementId}" displayALL="{!v.displayALL}" chatZoom="{!v.chatZoom}" vfURL="https://penny1.my.salesforce.com/apex/PennyWordCloudVF" autoScroll="true" />
</aura:application>