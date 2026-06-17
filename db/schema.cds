namespace com.epm;

using {
  cuid,
  managed,
  Currency,
  Country
} from '@sap/cds/common';

entity Suppliers : cuid {
  name     : String(100);
  contact  : String(100);
  email    : String(120);
  phone    : String(20);
  city     : String(50);
  country  : Country;
  isActive : Boolean default true;
}

entity Categories : cuid {
  name           : String(100);
  description    : String(255);
  parentCategory : Association to Categories;
}

entity Products : cuid, managed {
  name        : String(100);
  description : String(255);
  price       : Decimal(10,2);
  currency    : Currency;
  stock       : Integer;
  minStock    : Integer;
  rating      : Decimal(2,1);
  supplier    : Association to Suppliers;
  category    : Association to Categories;
}

entity Customers : cuid, managed {
  name        : String(100);
  email       : String(120);
  phone       : String(20);
  city        : String(50);
  country     : Country;
  creditLimit : Decimal(12,2);
}

entity SalesOrders : cuid, managed {
  orderNumber : String(30);
  customer    : Association to Customers;
  orderDate   : Date;
  totalAmount : Decimal(12,2);
  taxAmount   : Decimal(12,2);
  netAmount   : Decimal(12,2);
  currency    : Currency;
  status      : String(20);

  items       : Composition of many SalesOrderItems
                  on items.order = $self;
}

entity SalesOrderItems : cuid {
  order     : Association to SalesOrders;
  product   : Association to Products;
  quantity  : Integer;
  unitPrice : Decimal(10,2);
  netAmount : Decimal(12,2);
}

entity PurchaseOrders : cuid, managed {
  poNumber    : String(30);
  supplier    : Association to Suppliers;
  orderDate   : Date;
  totalAmount : Decimal(12,2);
  taxAmount   : Decimal(12,2);
  netAmount   : Decimal(12,2);
  currency    : Currency;
  status      : String(20);
  virtual criticality : Integer;
  //added if not deleted, otherwise the UI will not update the buttons after submit/approve/reject/receive actions
  virtual submitEnabled    : Boolean;
  virtual approveEnabled   : Boolean;
  virtual rejectEnabled    : Boolean;
  virtual receiveEnabled   : Boolean;
  virtual poNumberEditable : Integer;   // FieldControl: 1=read-only, 7=editable
  virtual supplierEditable : Integer;
  items       : Composition of many PurchaseOrderItems
                  on items.order = $self;
}

entity PurchaseOrderItems : cuid {
  order     : Association to PurchaseOrders;
  product   : Association to Products;
  quantity  : Integer;
  unitPrice : Decimal(10,2);
}