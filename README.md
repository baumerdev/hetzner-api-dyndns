# Hetzner DynDNS Docker

A small Docker image to dynamically update DNS records using the [Hetzner DNS-API](https://www.hetzner.com/dns-console/).

It's just a single bash script, running on Alpine and using only curl, dig and jq. It will update (or create) a DNS record in a zone to the current public IP address.

## Installation

### Generate Access Token

First, a new access token must be created in the [Hetzner DNS Console](https://dns.hetzner.com/). This should be copied immediately, because for security reasons it will not be possible to display the token later.

**Hetzner DNS API Doc:**

https://dns.hetzner.com/api-docs/

### Usage

This quick set up will start the container and update the DNS record every 5 minutes.

```bash
docker run \
-e HETZNER_AUTH_API_TOKEN=<your-hetzner-dns-api-token> \
-e HETZNER_ZONE_NAME=<your-zone> \
-e HETZNER_RECORD_NAME=<your-record> \
--restart=always \
baumerdev/hetzner-dyndns:latest
```

## Configuration

### Environment Variables

|NAME                       | Required | Default               | Description                                                                        |
|:--------------------------|:---------|:----------------------|:-----------------------------------------------------------------------------------|
|**HETZNER_AUTH_API_TOKEN** | ✔        |                       | Your Hetzner API access token                                                      |
|**HETZNER_ZONE_NAME**      | ✔        |                       | The zone name a.k.a the domain name.                                               |
|**HETZNER_RECORD_NAME**    | ✔        |                       | The record name a.k.a the subdomain. '@' to set the record for the zone itself.    |
|HETZNER_ZONE_ID            |          |                       | The zone ID to update. If not provided, the script will get the ID from the API.   |
|HETZNER_RECORD_ID          |          |                       | The record ID to update. If not provided, the script will get the ID from the API. |
|HETZNER_RECORD_TTL         |          | 60                    | The TTL of the record.                                                             |
|HETZNER_RECORD_TYPE        |          | A                     | The record type. Either A for IPv4 or AAAA for IPv6.                               |
|HETZNER_NAMESERVER         |          | oxygen.ns.hetzner.com | Nameserver for checking if anything is up-to-date.                                 |
|CRON                       |          | */5 * * * *           | Crontab time fields                                                                |

**Note:** If the record does not exist, the script will create it. If you provide a zone ID and record ID they must match the zone and record name.

### Getting zone ID and record ID

Zone ID and record ID can be provided which will reduce the amount of API calls otherwise the script will get the IDs from the API.

### Get all zones

If you want to get all zones in your account and check the desired Zone ID.

```
# Replace <your-hetzner-dns-api-token> with your data
curl "https://dns.hetzner.com/api/v1/zones" -H \
'Auth-API-Token: <your-hetzner-dns-api-token>' | jq
```

### Get a record ID

If you want to get a record ID manually you may use the following curl command.

```
# Replace <zone_id>, <your-hetzner-dns-api-token>, <record_type>, <record_name> with your data
curl -s --location \
    --request GET 'https://dns.hetzner.com/api/v1/records?zone_id=<zone_id>' \
    --header 'Auth-API-Token: <your-hetzner-dns-api-token>' | \
    jq --raw-output '.records[] | select(.type == "'<record_type>'") | select(.name == "'<record_name>'") | .id'
```

### Multiple Domains/Subdomains/Types

You can update multiple domains/subdomains by either running multiple containers with different environment variables or by setting up CNAMES in the DNS zone via Hetzner DNS-API and point them to the A/AAAA record you update.

If you want to update IPv4 and IPv6, you have run multiple containers with different environment variables.

## Build

You can build the image yourself.

```bash
docker build -t baumerdev/hetzner-dyndns .
```

## Original script

This is a fork of the original repository [FarrowStrange/hetzner-api-dyndns](https://github.com/FarrowStrange/hetzner-api-dyndns)

Apart from modifications for Docker, the following changes have been made:

  * It contains some pull requests that have yet not been merged into the original repository.
  * Some parameter are now mandatory.
  * It compares the current IP with the IP of the DNS record before calling the API.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
