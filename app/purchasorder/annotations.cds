using {PurchasingService} from '../../srv/purchasing-service';
using from '@sap/cds/common';

// =======================================================================
// PurchaseOrders
// =======================================================================
annotate PurchasingService.PurchaseOrders with @(
  UI: {

    SelectionFields: [
      poNumber,
      status,
      supplier_ID,
      orderDate
    ],

    LineItem: [
      {
        Value: poNumber,
        Label: 'PO Number'
      },
      {
        Value: supplier.name,
        Label: 'Supplier'
      },
      {
        Value: orderDate,
        Label: 'Order Date'
      },
      {
        Value: totalAmount,
        Label: 'Total Amount'
      },
      {
        Value: taxAmount,
        Label: 'Tax Amount'
      },
      {
        Value: netAmount,
        Label: 'Net Amount'
      },
      {
        Value: currency_code,
        Label: 'Currency'
      },
      {
        Value: status,
        Label: 'Status',
        Criticality: criticality
      }
    ],

    HeaderInfo: {
      TypeName: 'Purchase Order',
      TypeNamePlural: 'Purchase Orders',
      Title: {Value: poNumber},
      Description: {Value: supplier.name},
        TypeImageUrl : 'sap-icon://my-sales-order',
    },

    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup#General',
        Label: 'General Information'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Target: 'items/@UI.LineItem',
        Label: 'Purchase Order Items'
      }
    ],

    HeaderFacets: [
      {
        $Type: 'UI.ReferenceFacet',
        Label: 'Budget Utilization',
        Target: '@UI.DataPoint#BudgetUtilization'
      }
    ],

    FieldGroup #General: {
      Data: [
        {
          Value: poNumber,
          Label: 'PO Number'
        },
        {
          Value: supplier_ID,
          Label: 'Supplier'
        },
        {
          Value: orderDate,
          Label: 'Order Date'
        },
        {
          Value: totalAmount,
          Label: 'Total Amount'
        },
        {
          Value: taxAmount,
          Label: 'Tax Amount'
        },
        {
          Value: netAmount,
          Label: 'Net Amount'
        },
        {
          Value: currency_code,
          Label: 'Currency'
        },
        {
          Value: status,
          Label: 'Status'
        }
      ]
    },

    Identification: [
      {
        $Type: 'UI.DataFieldForAction',
        Action: 'PurchasingService.submit',
        Label: 'Submit'
      },
      {
        $Type: 'UI.DataFieldForAction',
        Action: 'PurchasingService.approve',
        Label: 'Approve'
      },
      {
        $Type: 'UI.DataFieldForAction',
        Action: 'PurchasingService.reject',
        Label: 'Reject'
      },
      {
        $Type: 'UI.DataFieldForAction',
        Action: 'PurchasingService.receive',
        Label: 'Receive'
      }
    ],

    DataPoint #totalAmount: {
      $Type: 'UI.DataPointType',
      Value: totalAmount,
      Title: 'Total Amount'
    },

    DataPoint #BudgetUtilization: {
      $Type: 'UI.DataPointType',
      Value: netAmount,
      TargetValue: 1500000,
      Title: 'Budget Utilization'
    }
  }
);

annotate PurchasingService.PurchaseOrders with {
  poNumber @(
    Core.Immutable,
    Common.Label : 'Po Number',
);

  supplier @(Common: {
    Text: supplier.name,
    TextArrangement: #TextOnly,
    ValueList: {
      CollectionPath: 'Suppliers',
      Parameters: [
        {
          $Type: 'Common.ValueListParameterInOut',
          LocalDataProperty: supplier_ID,
          ValueListProperty: 'ID'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'name'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'email'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'city'
        }
      ]
    }
  },
    Common.Label : 'Supplier ID',);
};

annotate PurchasingService.PurchaseOrders with @(
  Common.SideEffects #ItemsChanged: {
    SourceEntities: ['items'],
    TargetProperties: ['totalAmount']
  }
);


// =======================================================================
// PurchaseOrderItems
// =======================================================================
annotate PurchasingService.PurchaseOrderItems with @(
  UI: {

    LineItem: [
      {
        Value: product_ID,
        Label: 'Product'
      },
      {
        Value: quantity,
        Label: 'Quantity'
      },
      {
        Value: unitPrice,
        Label: 'Unit Price'
      }
    ],

    HeaderInfo: {
      TypeName: 'PO Item',
      TypeNamePlural: 'PO Items',
      Title: {Value: product.name},
      Description: {Value: order.poNumber},
      TypeImageUrl: 'sap-icon://sales-order-item'
    },

    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup#ItemDetail',
        Label: 'Item Details'
      },
      {
        $Type: 'UI.ReferenceFacet',
        Target: 'product/@UI.FieldGroup#ProductDetail',
        Label: 'Product Information'
      }
    ],

    HeaderFacets: [
      {
        $Type: 'UI.ReferenceFacet',
        ID: 'rating',
        Target: 'product/@UI.DataPoint#rating'
      },
      {
        $Type: 'UI.ReferenceFacet',
        ID: 'price',
        Target: 'product/@UI.DataPoint#price'
      },
      {
        $Type: 'UI.ReferenceFacet',
        ID: 'symbol',
        Target: 'product/currency/@UI.DataPoint#symbol'
      },
      {
        $Type: 'UI.ReferenceFacet',
        ID: 'stock',
        Target: 'product/@UI.DataPoint#stock'
      }
    ],

    FieldGroup #ItemDetail: {
      Data: [
        {
          Value: order.poNumber,
          Label: 'PO Number',
          ![@Common.FieldControl]: #ReadOnly
        },
        {
          Value: product_ID,
          Label: 'Product Name'
        },
        {
          Value: product.description,
          Label: 'Description'
        },
        {
          Value: quantity,
          Label: 'Quantity Ordered'
        },
        {
          Value: unitPrice,
          Label: 'Unit Price'
        },
        {
          Value: product.price,
          Label: 'Current Product Price'
        },
        {
          Value: product.stock,
          Label: 'Current Stock'
        },
        {
          Value: product.rating,
          Label: 'Rating'
        },
        {
          Value: product.supplier.name,
          Label: 'Supplier'
        }
      ]
    }
  }
);

annotate PurchasingService.PurchaseOrderItems with {
  product @(Common: {
    Text: product.name,
    TextArrangement: #TextOnly,
    ValueList: {
      CollectionPath: 'Products',
      Parameters: [
        {
          $Type: 'Common.ValueListParameterInOut',
          LocalDataProperty: product_ID,
          ValueListProperty: 'ID'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'name'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'price'
        },
        {
          $Type: 'Common.ValueListParameterDisplayOnly',
          ValueListProperty: 'stock'
        }
      ]
    }
  });
};

annotate PurchasingService.PurchaseOrderItems with @(
  Common.SideEffects: {
    SourceProperties: ['quantity', 'unitPrice'],
    TargetProperties: ['totalPrice']
  }
);


// =======================================================================
// Products
// =======================================================================
annotate PurchasingService.Products with @(
  UI: {

    HeaderInfo: {
      TypeName: 'Product',
      TypeNamePlural: 'Products',
      Title: {Value: name},
      Description: {Value: description}
    },

    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup#ProductDetail',
        Label: 'Product Details'
      }
    ],

    FieldGroup #ProductDetail: {
      Data: [
        {
          Value: name,
          Label: 'Product Name'
        },
        {
          Value: description,
          Label: 'Description'
        },
        {
          Value: price,
          Label: 'Price'
        },
        {
          Value: stock,
          Label: 'Stock'
        },
        {
          Value: minStock,
          Label: 'Minimum Stock'
        },
        {
          Value: rating,
          Label: 'Rating'
        },
        {
          Value: supplier.name,
          Label: 'Supplier'
        }
      ]
    },

    DataPoint #rating: {
      $Type: 'UI.DataPointType',
      Value: rating,
      Title: 'Rating',
      TargetValue: 5,
      Visualization: #Rating
    },

    DataPoint #price: {
      $Type: 'UI.DataPointType',
      Value: price,
      Title: 'Price'
    },

    DataPoint #stock: {
      $Type: 'UI.DataPointType',
      Value: stock,
      Title: 'Stock'
    },

    DataPoint #currency_code: {
      $Type: 'UI.DataPointType',
      Value: currency_code,
      Title: 'currency_code'
    }
  }
);

annotate PurchasingService.Products with {
  supplier
    @Common.Text: supplier.name
    @Common.TextArrangement: #TextOnly;
};


annotate PurchasingService.PurchaseOrders with actions {
  submit  @(Core.OperationAvailable: submitEnabled);
  approve @(Core.OperationAvailable: approveEnabled);
  reject  @(Core.OperationAvailable: rejectEnabled);
  receive @(Core.OperationAvailable: receiveEnabled);
};


// =======================================================================
// Currencies
// =======================================================================
annotate PurchasingService.Currencies with @(
  UI.DataPoint #symbol: {
    $Type: 'UI.DataPointType',
    Value: symbol,
    Title: 'Currency Symbol'
  }
);
annotate PurchasingService.PurchaseOrders with {
    status @Common.Label : 'Status'
};

annotate PurchasingService.PurchaseOrders with {
    orderDate @Common.Label : 'Order Date'
};

