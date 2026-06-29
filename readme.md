# EPM CAP/BTP Project

This project is a SAP CAP application with an SAP Fiori/UI5 purchase order app and an approuter for SAP BTP Cloud Foundry deployment.

## Project Layout

| Path | Purpose |
| --- | --- |
| `db/` | Domain model and CSV seed data |
| `srv/` | CAP service definitions and handlers |
| `app/purchasorder/webapp/` | Source for the Fiori purchase order app |
| `app/router/` | Approuter configuration used by the MTA deployment |
| `mta.yaml` | Multi-target application descriptor for BTP deployment |
| `xs-security.json` | XSUAA scopes, roles, and role collections |

Generated folders such as `gen/`, `resources/`, `app/*/dist/`, `node_modules/`, and MTA archives should not be committed.

## Local Development

Install dependencies:

```sh
npm ci
```

Run CAP locally with mocked users:

```sh
npm run watch or cds watch
```

Useful mock users are defined in `package.json`:

| User | Password | Roles |
| --- | --- | --- |
| `alice` | `alice` | PurchaseManager, Viewer |
| `bob` | `bob` | PurchaseManager, Viewer |
| `carol` | `carol` | Viewer |
| `dave` | `dave` | Administrator, PurchaseManager, Viewer |

## HTML5 Application Repository Deployment

This project is configured to deploy the Fiori app to the SAP BTP HTML5 Application Repository. The MTA creates:

| Resource/Module | Purpose |
| --- | --- |
| `epm-html5-repo-host` | Stores the built HTML5 app |
| `epm-destination-service` | Enables HTML5 runtime and backend destinations |
| `epm-app-content` | Uploads `purchasorder.zip` to the HTML5 repository |
| `epm-destination-content` | Creates/updates destinations used by the HTML5 runtime |
| `epm-api` destination | Routes the HTML5 app to the CAP service |

Build the deployable MTAR:

```sh
mbt build
```

Deploy it to your targeted Cloud Foundry space:

```sh
cf deploy mta_archives/epm_1.0.0.mtar
```

After deployment, open SAP BTP Cockpit and check **HTML5 Applications** in the same subaccount. The app should appear from the `purchasorder` HTML5 module. If it is not visible immediately, refresh the page after a short wait and confirm that the destination service has `HTML5Runtime_enabled` set to `true`.

## Build

Validate and generate deployable CAP artifacts:

```sh
npm run build
```

Build the MTA archive for Cloud Foundry:

```sh
mbt build
```

Deploy the generated archive:

```sh
cf deploy mta_archives/epm_1.0.0.mtar
```
