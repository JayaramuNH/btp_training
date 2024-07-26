
@cds.persistence.exists 
@cds.persistence.calcview 
Entity CV_PO_ANA {
key     BP_ID: String(32)  @title: 'BP_ID: BP_ID' ; 
key     EMAIL_ADDRESS: String(105)  @title: 'EMAIL_ADDRESS: EMAIL_ADDRESS' ; 
key     NODE_KEY: String(32)  @title: 'NODE_KEY: NODE_KEY' ; 
key     PO_ID: Integer  @title: 'PO_ID: PO_ID' ; 
key     OVERALL_STATUS: String(1)  @title: 'OVERALL_STATUS: OVERALL_STATUS' ; 
key     CURRENCY_CODE: String(3)  @title: 'CURRENCY_CODE: CURRENCY_CODE' ; 
        NET_AMOUNT: Decimal(15)  @title: 'NET_AMOUNT: NET_AMOUNT' ; 
        TAX_AMOUNT: Decimal(15)  @title: 'TAX_AMOUNT: TAX_AMOUNT' ; 
}
