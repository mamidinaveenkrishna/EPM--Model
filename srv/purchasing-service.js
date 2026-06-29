const cds = require('@sap/cds');

module.exports = function () {

  // ---------------------------------------------------------------------
  // Validation at draft-save time (before activation)
  // ---------------------------------------------------------------------
  this.before('SAVE', 'PurchaseOrders', (req) => {
    if (!req.data.poNumber || req.data.poNumber.trim() === '') {
      req.error(400, 'PO Number is required');
    }
    if (!req.data.supplier_ID) {
      req.error(400, 'Supplier is required');
    }
  });

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

  this.on('submit', 'PurchaseOrders', async (req) => {
    console.log("TARGET =", req.target.name);

    const { ID } = req.params[0];

    const po = await SELECT.one.from('com.epm.PurchaseOrders').where({ ID });
    if (!po) req.reject(404, 'Purchase Order not found');

    if (po.status !== 'Draft') {
      req.reject(400, `Only Draft POs can be submitted. Current status: ${po.status}`);
    }

    const items = await SELECT.from('com.epm.PurchaseOrderItems')
      .where({ order_ID: ID });

    if (items.length === 0) {
      req.reject(400, 'PO must have at least one item');
    }

    const total = items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0);

    await UPDATE('com.epm.PurchaseOrders')
      .set({
        status: 'Submitted',
        totalAmount: +total.toFixed(2)
      })
      .where({ ID });

    const supplier = await SELECT.one.from('com.epm.Suppliers')
      .where({ ID: po.supplier_ID });

    await this.emit('POSubmitted', {
      poId: ID,
      poNumber: po.poNumber,
      supplierName: supplier?.name || 'Unknown',
      totalAmount: +total.toFixed(2),
      submittedBy: req.user.id
    });

    return {
      status: 'Submitted',
      message: `PO ${po.poNumber} submitted for approval`
    };
  });

  this.on('approve', 'PurchaseOrders', async (req) => {
    const { ID } = req.params[0];
    const { comment } = req.data;

    const po = await SELECT.one.from('com.epm.PurchaseOrders').where({ ID });
    if (!po) req.reject(404, 'Purchase Order not found');

    if (po.status !== 'Submitted') {
      req.reject(400, `Only Submitted POs can be approved. Current status: ${po.status}`);
    }

    await UPDATE('com.epm.PurchaseOrders')
      .set({ status: 'Approved' })
      .where({ ID });

    await this.emit('POApproved', {
      poId: ID,
      poNumber: po.poNumber,
      approvedBy: req.user.id,
      comment: comment || ''
    });

    return {
      status: 'Approved',
      message: `PO ${po.poNumber} approved`,
      approvedAt: new Date().toISOString()
    };
  });

  this.on('reject', 'PurchaseOrders', async (req) => {
    const { ID } = req.params[0];
    const { reason } = req.data;

    const po = await SELECT.one.from('com.epm.PurchaseOrders').where({ ID });
    if (!po) req.reject(404, 'Purchase Order not found');

    if (po.status !== 'Submitted') {
      req.reject(400, `Only Submitted POs can be rejected. Current status: ${po.status}`);
    }

    if (!reason || reason.trim() === '') {
      req.reject(400, 'Rejection reason is required');
    }

    await UPDATE('com.epm.PurchaseOrders')
      .set({ status: 'Rejected' })
      .where({ ID });

    await this.emit('PORejected', {
      poId: ID,
      poNumber: po.poNumber,
      rejectedBy: req.user.id,
      reason
    });

    return {
      status: 'Rejected',
      message: `PO ${po.poNumber} rejected. Reason: ${reason}`
    };
  });

  this.on('receive', 'PurchaseOrders', async (req) => {
    const { ID } = req.params[0];
    const { receivedQty, notes } = req.data;

    const po = await SELECT.one.from('com.epm.PurchaseOrders').where({ ID });
    if (!po) req.reject(404, 'Purchase Order not found');

    if (po.status !== 'Approved') {
      req.reject(400, `Only Approved POs can be received. Current status: ${po.status}`);
    }

    await UPDATE('com.epm.PurchaseOrders')
      .set({ status: 'Received' })
      .where({ ID });

    const items = await SELECT.from('com.epm.PurchaseOrderItems')
      .where({ order_ID: ID });

    for (const item of items) {
      const product = await SELECT.one.from('com.epm.Products')
        .where({ ID: item.product_ID });

      if (product) {
        // Use receivedQty if provided (e.g. partial receipt against this item),
        // otherwise fall back to the full ordered quantity for this item.
        const qtyToAdd = (receivedQty != null) ? receivedQty : item.quantity;

        await UPDATE('com.epm.Products')
          .set({ stock: product.stock + qtyToAdd })
          .where({ ID: item.product_ID });
      }
    }

    return {
      status: 'Received',
      message: `PO ${po.poNumber} received. Stock updated for ${items.length} products.${notes ? ' Notes: ' + notes : ''}`
    };
  });

  this.on('getSummary', 'PurchaseOrders', async (req) => {
    const { ID } = req.params[0];

    const po = await SELECT.one.from('com.epm.PurchaseOrders').where({ ID });
    if (!po) req.reject(404, 'Purchase Order not found');

    const items = await SELECT.from('com.epm.PurchaseOrderItems')
      .where({ order_ID: ID });

    const supplier = await SELECT.one.from('com.epm.Suppliers')
      .where({ ID: po.supplier_ID });

    const createdDate = new Date(po.createdAt || po.orderDate);
    const today = new Date();
    const daysOpen = Math.floor((today - createdDate) / (1000 * 60 * 60 * 24));

    return {
      poNumber: po.poNumber,
      supplier: supplier?.name || 'Unknown',
      itemCount: items.length,
      totalAmount: +(po.totalAmount || 0).toFixed(2),
      status: po.status,
      daysOpen
    };
  });

  this.on('getPurchasingDashboard', async () => {
    const allPOs = await SELECT.from('com.epm.PurchaseOrders');

    return {
      totalPOs: allPOs.length,
      draftCount: allPOs.filter(p => p.status === 'Draft').length,
      pendingApproval: allPOs.filter(p => p.status === 'Submitted').length,
      approvedCount: allPOs.filter(p => p.status === 'Approved').length,
      rejectedPOCount: allPOs.filter(p => p.status === 'Rejected').length,
      totalSpend: +allPOs
        .filter(p => ['Approved', 'Received'].includes(p.status))
        .reduce((sum, p) => sum + (p.totalAmount || 0), 0)
        .toFixed(2)
    };
  });

  // ---------------------------------------------------------------------
  // Event log handlers
  // ---------------------------------------------------------------------

  this.on('POSubmitted', (msg) => {
    const { poNumber, supplierName, totalAmount, submittedBy } = msg.data;
    console.log(`PO SUBMITTED: ${poNumber}, Supplier: ${supplierName}, Amount: ${totalAmount}, By: ${submittedBy}`);
  });

  this.on('POApproved', (msg) => {
    const { poNumber, approvedBy, comment } = msg.data;
    console.log(`PO APPROVED: ${poNumber}, By: ${approvedBy}, Comment: ${comment}`);
  });

  this.on('PORejected', (msg) => {
    const { poNumber, rejectedBy, reason } = msg.data;
    console.log(`PO REJECTED: ${poNumber}, By: ${rejectedBy}, Reason: ${reason}`);
  });

  // ---------------------------------------------------------------------
  // READ: compute criticality + action-availability flags
  // ---------------------------------------------------------------------
  this.after('READ', 'PurchaseOrders', (data) => {

    const records = Array.isArray(data) ? data : [data];

    records.filter(Boolean).forEach(po => {

      switch (po.status) {
        case 'Approved':
        case 'Received':
          po.criticality = 3; // Green
          break;

        case 'Submitted':
          po.criticality = 2; // Orange
          break;

        case 'Draft':
          po.criticality = 5; // Blue (Information)
          break;

        case 'Rejected':
          po.criticality = 1; // Red
          break;

        default:
          po.criticality = 0;
      }

      // Action availability flags (used with @Core.OperationAvailable)
      po.submitEnabled  = po.status === 'Draft';
      po.approveEnabled = po.status === 'Submitted';
      po.rejectEnabled  = po.status === 'Submitted';
      po.receiveEnabled = po.status === 'Approved';
      if(po.status === 'Draft') {
        po.poNumberEditable = 7; // editable
        po.supplierEditable = 7;
      } else {
        po.poNumberEditable = 1; // read-only
        po.supplierEditable = 1;
      }
    });

  });
};
