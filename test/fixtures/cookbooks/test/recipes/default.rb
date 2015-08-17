marketplace_image node['test']['role'] do
  platform node['test']['platform']
  default_user node['test']['default_user']
  support_email node['test']['support_email']
  reporting_cron node['test']['reporting_cron']
  publish node['test']['publish']
  disable_outbound_traffic node['test']['disable_outbound_traffic']
  license_count node['test']['license_count']
  doc_url node['test']['doc_url']
  product_code node['test']['product_code']
end
