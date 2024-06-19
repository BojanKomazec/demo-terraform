Goal:
- get the list of all availability zones (AZ) in a given region and add them to the list
- for each AZ calculate two CIDR ranges: one for public and one for private network
- set VPC CIDR in a variable and calculate all ranges relative to it
- public ranges should be in one output variable and private subranges in another