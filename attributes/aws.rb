default['marketplace_image']['aws']['public']['aio']['ami'] = 'ami-1e2c0a74'
default['marketplace_image']['aws']['public']['aio']['products'] = [
  { 'node_count' => 5, 'product_code' => 'dzsysio0zch27uban3y1c6wh7' },
  { 'node_count' => 25, 'product_code' => '349645nlgkwcdfb8ndjeiwwp7' },
  { 'node_count' => 50, 'product_code' => 'ckwjikuom9b37yaprlidzbqps' },
  { 'node_count' => 100, 'product_code' => 'q995h875sbckcpafm8up762' },
  { 'node_count' => 150, 'product_code' => '28ac4pvihsw8uoy2sukb0ihzu' },
  { 'node_count' => 200, 'product_code' => '3nmsqv0670zsfjnqfnyd7lmdi' },
  { 'node_count' => 250, 'product_code' => 'cfnnw6j8s75mhj3i5na0t4afq' }
]

default['marketplace_image']['aws']['public']['flexible_aio']['ami'] = 'ami-304e6d5a'
default['marketplace_image']['aws']['public']['flexible_aio']['products'] = [
  { 'node_count' => 0, 'product_code' => 'dlna41ywkqax795eganhflsm8' }
]

default['marketplace_image']['aws']['public']['compliance']['ami'] = 'ami-dcfcdbb6'
default['marketplace_image']['aws']['public']['compliance']['products'] = [
  { 'node_count' => 5, 'product_code' => '148p1m5zz5zhinwoggpqeavis' },
  { 'node_count' => 25, 'product_code' => '7vylx7v9xdlma0mj2apjyix9w' },
  { 'node_count' => 50, 'product_code' => 'c8vcwhxd8seccf77fz1ccgpe4' },
  { 'node_count' => 100, 'product_code' => 'a5mqx9w3n56pvjedo8iw0toj2' },
  { 'node_count' => 150, 'product_code' => 'gg239559lun7g9v74fc9caj5' },
  { 'node_count' => 200, 'product_code' => '86ocpc6jfmdp9jcej5oyji1rz' },
  { 'node_count' => 250, 'product_code' => 'ezw9hgu9mtlvqwkayp5gw15is' }
]

default['marketplace_image']['aws']['public']['flexible_compliance']['ami'] = 'ami-db4c6fb1'
default['marketplace_image']['aws']['public']['flexible_compliance']['products'] = [
  { 'node_count' => 0, 'product_code' => '8a3w64phkkutljzrbdqjrmc8f' }
]

default['marketplace_image']['aws']['ic']['aio']['ami'] = 'ami-304e6d5a'
default['marketplace_image']['aws']['ic']['aio']['products'] = [
  { 'node_count' => 5, 'product_code' => 'dgivcepn261oi5ul0fdxu6drf' },
  { 'node_count' => 25, 'product_code' => 'cntn7cg2u1iiwv0eah6fnkkbj' },
  { 'node_count' => 50, 'product_code' => 'ax4j22h69yeb5824i1qhobdaw' },
  { 'node_count' => 100, 'product_code' => 'dqbbw3v3mqcm5vvr8fdgrw0cy' },
  { 'node_count' => 150, 'product_code' => 'dqvg1zvlvsch9fsnajua0e3df' },
  { 'node_count' => 200, 'product_code' => '6p9oh9isrga3p00bwfobn8gr0' },
  { 'node_count' => 250, 'product_code' => 'c4yh8519ogsqr344akhv9jk91' }
]

default['marketplace_image']['aws']['ic']['compliance']['ami'] = 'ami-dcfcdbb6'
default['marketplace_image']['aws']['ic']['compliance']['products'] = [
  { 'node_count' => 5, 'product_code' => 'es45a780wiqmxb7wzcxsnqoho' },
  { 'node_count' => 25, 'product_code' => 'pa64tibm2rwx0azxn51cgq48' },
  { 'node_count' => 50, 'product_code' => 'e3z71pfxnk7r22tx11fxjsso' },
  { 'node_count' => 100, 'product_code' => 'bjg704s75oq34nrg9sg9zex8v' },
  { 'node_count' => 150, 'product_code' => '1igoiq6sm5nq6j4tbzr9p2z3z' },
  { 'node_count' => 200, 'product_code' => '5igut39qk86ttq9qztlhmncrb' },
  { 'node_count' => 250, 'product_code' => 'bv1cblebexhoamj2ief0t3sih' }
]

default['marketplace_image']['aws']['compliance']['doc_url'] = 'https://docs.chef.io/install_compliance.html#amazon-aws-marketplace'
default['marketplace_image']['aws']['aio']['doc_url'] = 'https://docs.chef.io/aws_marketplace.html'
