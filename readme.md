# Getting Started

Welcome to your new CAP project.

It contains these folders and files, following our recommended project layout:

File or Folder | Purpose
---------|----------
`app/` | content for UI frontends goes here
`db/` | your domain models and data go here
`srv/` | your service models and code go here
`readme.md` | this getting started guide

## Next Steps

- Open a new terminal and run `cds watch`
- (in VS Code simply choose _**Terminal** > Run Task > cds watch_)
- Start with your domain model, in a CDS file in `db/`

## Learn More

Learn more at <https://cap.cloud.sap>.


### Assignment

Filter Expression
1."Show me all products that cost more than $50" → $filter=price gt 50
2."Find customers from India" → $filter=country eq 'India'
3."Get all active employees" → $filter=isActive eq true
4."Show orders placed after March 2026" → $filter=orderDate gt 2026-03-31
5."Find books with 'Lord' in the title" → $filter=contains(title, 'Lord')
6."Products with stock between 10 and 100" → $filter=stock ge 10 and stock le 100
7."Authors from UK or USA" → $filter=country eq 'UK' or country eq 'USA'
8."Orders that are NOT delivered and cost over $500" → $filter=not (status eq 'Delivered') and totalAmount gt 500