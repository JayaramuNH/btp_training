namespace mycap.db.common; 

using { Currency } from '@sap/cds/common';

type Gender : String(1) enum{
    male = 'M';
    female = 'F';
    nonBinary = 'N';
    noDisclosure = 'D';
    selfDescribe = 'S';
};

type AmountT : Decimal(15,2)@(
    Semantics.amount.currencyCode: 'CURRENCY_CODE',
    sap.unit: 'CURRENCY_CODE'
);


aspect Amount {
    Currency: Currency;	
    GROSS_AMOUNT:AmountT;	
    NET_AMOUNT:AmountT;
    TAX_AMOUNT:AmountT;     
}

type PhoneNumber : String(30);
type Email: String(255);