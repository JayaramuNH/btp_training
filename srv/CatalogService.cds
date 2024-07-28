using {
    mycap.db.master,
    mycap.db.transaction,
    mycap.db.CDSViews
} from '../db/datamodel';

using {CV_PO_ANA} from '../db/exposer';

service CatalogService @(path: '/CatalogService') {

    function sleep() returns Boolean;

    @readonly
    entity CVPOAnalytics                      as projection on CV_PO_ANA;

    entity EmployeeSet                        as projection on master.employees;
    entity AddressSet                         as projection on master.address;
    entity ProductSet                         as projection on master.product;
    entity BPSet                              as projection on master.businesspartner;

    entity POs @(title: '{i18n>poHeader}')    as
        projection on transaction.purchaseorder {
            *,
            case LIFECYCLE_STATUS
            when 'N' then 'New'
            when 'B' then 'Blocked'
            when 'D' then 'Delivered'
            end as LIFECYCLE_STATUS: String(20),
        case LIFECYCLE_STATUS
            when 'N' then 2
            when 'B' then 1
            when 'D' then 3
            end as Criticality: Integer,
            Items : redirected to POItems
        }
        actions {
            function largestOrder() returns array of POs;
            action   boost();
        }

        annotate POs with @odata.draft.enabled;

    entity POItems @(title: '{i18n>poItems}') as
        projection on transaction.poitems {
            *,
            PARENT_KEY   : redirected to POs,
            PRODUCT_GUID : redirected to ProductSet
        }

    entity POWorklist                         as projection on CDSViews.POWorklist;
    entity ProductOrders                      as projection on CDSViews.ProductViewSub;
    entity ProductAggregation                 as projection on CDSViews.CProductValuesView;
// excluding {
//     ProductId
// };

}
