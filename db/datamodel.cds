namespace mycap.db;

using {
    cuid,
    Currency
} from '@sap/cds/common';
using {mycap.db.common} from './common';

type Guid : String(32);


context master {
    entity businesspartner {
        key NODE_KEY      : Guid;
            BP_ROLE       : String(2);
            EMAIL_ADDRESS : String(105);
            PHONE_NUMBER  : String(32);
            FAX_NUMBER    : String(32);
            WEB_ADDRESS   : String(44);
            ADDRESS_GUID  : Association to address;
            BP_ID         : String(32);
            COMPANY_NAME  : String(250);
    }

    annotate businesspartner with {
        NODE_KEY @title: '{i18n>bp_key}';
        BP_ROLE  @title: '{i18n>bp_role}';
    };

    entity address {
        key NODE_KEY        : Guid;
            CITY            : String(44);
            POSTAL_CODE     : String(8);
            STREET          : String(44);
            BUILDING        : String(128);
            COUNTRY         : String(44);
            ADDRESS_TYPE    : String(44);
            VAL_START_DATE  : Date;
            VAL_END_DATE    : Date;
            LATITUDE        : Decimal;
            LONGITUDE       : Decimal;
            businesspartner : Association to one businesspartner
                                  on businesspartner.ADDRESS_GUID = $self;
    }

    entity prodtext {
        key NODE_KEY   : Guid;
            PARENT_KEY : Guid;
            LANGUAGE   : String(2);
            TEXT       : String(256);
    }

    entity product {
        key NODE_KEY       : Guid;
            PRODUCT_ID     : String(28);
            TYPE_CODE      : String(2);
            CATEGORY       : String(32);
            DESC_GUID      : Association to prodtext;
            SUPPLIER_GUID  : Association to master.businesspartner;
            TAX_TARIF_CODE : Integer;
            MEASURE_UNIT   : String(2);
            WEIGHT_MEASURE : Decimal;
            WEIGHT_UNIT    : String(2);
            CURRENCY_CODE  : String(4);
            PRICE          : Decimal(15, 2);
            WIDTH          : Decimal;
            DEPTH          : Decimal;
            HEIGHT         : Decimal;
            DIM_UNIT       : String(2);
            DESCRIPTION    : String(256);
    }

    entity employees : cuid {
        nameFirst     : String(40);
        nameMiddle    : String(40);
        nameLast      : String(40);
        nameInitials  : String(40);
        sex           : common.Gender;
        language      : String(1);
        phoneNumber   : common.PhoneNumber;
        email         : common.Email;
        loginName     : String(12);
        Currency      : Currency;
        salaryAmount  : common.AmountT;
        accountNumber : String(16);
        bankId        : String(20);
        bankName      : String(64);
    }
}

context transaction {

    entity purchaseorder : common.Amount, cuid {
        PO_ID            : Integer;
        PARTNER_GUID     : Association to master.businesspartner;
        LIFECYCLE_STATUS : String(1);
        OVERALL_STATUS   : String(1);
        Items            : Composition of many poitems
                               on Items.PARENT_KEY = $self;
        NOTE             : String(256);
        CREATEDBY        : UUID;
        MODIFIEDBY       : UUID;
        CREATEDAT        : Date;
        MODIFIEDAT       : Date;
    }

    entity poitems : common.Amount, cuid {
        PARENT_KEY   : Association to purchaseorder;
        PO_ITEM_POS  : Integer;
        PRODUCT_GUID : Association to master.product;

    }

}


context CDSViews {

    define view ![POWorklist] as
        select from transaction.purchaseorder {
            key PO_ID                             as ![PurchaseOrderId],
                PARTNER_GUID.BP_ID                as ![PartnerId],
                PARTNER_GUID.COMPANY_NAME         as ![CompanyName],
                GROSS_AMOUNT                      as ![POGrossAmount],
                Currency.code                     as ![POCurrencyCode],
                LIFECYCLE_STATUS                  as ![POStatus],
            key Items.PO_ITEM_POS                 as ![ItemPosition],
                Items.PRODUCT_GUID.PRODUCT_ID     as ![ProductId],
                Items.PRODUCT_GUID.DESCRIPTION    as ![ProductName],
                PARTNER_GUID.ADDRESS_GUID.CITY    as ![City],
                PARTNER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
                Items.GROSS_AMOUNT                as ![GrossAmount],
                Items.NET_AMOUNT                  as ![NetAmount],
                Items.TAX_AMOUNT                  as ![TaxAmount],
                Items.Currency.code               as ![CurrencyCode],
        };

    define view ProductValueHelp as
        select from master.product {
            @EndUserText.label: [{
                language: 'EN',
                text    : 'Product ID'
            }, {
                language: 'DE',
                text    : 'Prodekt ID'
            }]
            PRODUCT_ID  as ![ProductId],
            @EndUserText.label: [{
                language: 'EN',
                text    : 'Product Description'
            }, {
                language: 'DE',
                text    : 'Prodekt Description'
            }]
            DESCRIPTION as ![Description]
        };

    define view ![ItemView] as
        select from transaction.poitems {
            PARENT_KEY.PARTNER_GUID.NODE_KEY as ![Partner],
            PRODUCT_GUID.NODE_KEY            as ![ProductId],
            Currency.code                    as ![CurrencyCode],
            GROSS_AMOUNT                     as ![GrossAmount],
            NET_AMOUNT                       as ![NetAmount],
            TAX_AMOUNT                       as ![TaxAmount],
            PARENT_KEY.OVERALL_STATUS        as ![POStatus]
        };

    define view ProductViewSub as
        select from master.product as prod {
            key PRODUCT_ID  as ![ProductId],
                DESCRIPTION as ![Description],
                (
                    select from transaction.poitems as a {
                        round(
                            SUM(
                                a.GROSS_AMOUNT
                            ), 2
                        ) as SUM
                    }
                    where
                        a.PRODUCT_GUID.NODE_KEY = prod.NODE_KEY
                )           as PO_SUM : Decimal(10, 2)
        };

    define view ProductView as
        select from master.product
        mixin {
            PO_ORDERS : Association[ * ] to ItemView
                            on PO_ORDERS.ProductId = $projection.ProductId
        }
        into {
            key NODE_KEY                           as ![ProductId],
                DESCRIPTION,
                CATEGORY                           as ![Category],
                PRICE                              as ![Price],
                TYPE_CODE                          as ![TypeCode],
                SUPPLIER_GUID.BP_ID                as ![BPId],
                SUPPLIER_GUID.COMPANY_NAME         as ![CompanyName],
                SUPPLIER_GUID.ADDRESS_GUID.CITY    as ![City],
                SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
                //Exposed Association, which means when someone read the view
                //the data for orders wont be read by default
                //until unless someone consume the association
                PO_ORDERS
        };

    define view CProductValuesView as
        select from ProductView {
            key ProductId,
            key Country,
                PO_ORDERS.CurrencyCode as ![CurrencyCode],
                round(
                    sum(
                        PO_ORDERS.GrossAmount
                    ), 2
                )                      as ![POGrossAmount] : Decimal(10, 2)
        }
        group by
            ProductId,
            Country,
            PO_ORDERS.CurrencyCode

}
