# -*- coding:binary -*-

require 'spec_helper'
require 'rex/proto/kerberos/pac/krb5_pac'

RSpec.describe Rex::Proto::Kerberos::Pac::Krb5Pac do
  subject(:pac) do
    described_class.new
  end

  let(:sample) do
    "\x04\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\xb0\x01\x00\x00" \
    "\x48\x00\x00\x00\x00\x00\x00\x00\x0a\x00\x00\x00\x12\x00\x00\x00" \
    "\xf8\x01\x00\x00\x00\x00\x00\x00\x06\x00\x00\x00\x14\x00\x00\x00" \
    "\x10\x02\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x14\x00\x00\x00" \
    "\x28\x02\x00\x00\x00\x00\x00\x00\x01\x10\x08\x00\xcc\xcc\xcc\xcc" \
    "\xa0\x01\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x1e\x7c\x42" \
    "\xfc\x18\xd0\x01\xff\xff\xff\xff\xff\xff\xff\x7f\xff\xff\xff\xff" \
    "\xff\xff\xff\x7f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\xff\xff\xff\xff\xff\xff\xff\x7f\x08\x00\x08\x00" \
    "\x02\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00" \
    "\x04\x00\x00\x00\x00\x00\x00\x00\x05\x00\x00\x00\x00\x00\x00\x00" \
    "\x06\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00" \
    "\xe8\x03\x00\x00\x01\x02\x00\x00\x05\x00\x00\x00\x08\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x09\x00\x00\x00\x14\x00\x14\x00" \
    "\x0a\x00\x00\x00\x0b\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x10\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00" \
    "\x6a\x00\x75\x00\x61\x00\x6e\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x05\x00\x00\x00\x01\x02\x00\x00\x07\x00\x00\x00" \
    "\x00\x02\x00\x00\x07\x00\x00\x00\x08\x02\x00\x00\x07\x00\x00\x00" \
    "\x06\x02\x00\x00\x07\x00\x00\x00\x07\x02\x00\x00\x07\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0a\x00\x00\x00" \
    "\x00\x00\x00\x00\x0a\x00\x00\x00\x44\x00\x45\x00\x4d\x00\x4f\x00" \
    "\x2e\x00\x4c\x00\x4f\x00\x43\x00\x41\x00\x4c\x00\x04\x00\x00\x00" \
    "\x01\x04\x00\x00\x00\x00\x00\x05\x15\x00\x00\x00\x03\x99\xa8\x68" \
    "\xe0\x0e\x0e\xd9\x9a\x18\xcf\xcf\x00\x1e\x7c\x42\xfc\x18\xd0\x01" \
    "\x08\x00\x6a\x00\x75\x00\x61\x00\x6e\x00\x00\x00\x00\x00\x00\x00" \
    "\x07\x00\x00\x00\xf5\xb5\xdf\xc1\x14\xdd\x8e\x42\x8c\xfd\x09\x34" \
    "\xdc\x4e\x38\xcb\x00\x00\x00\x00\x07\x00\x00\x00\x07\xeb\x33\x91" \
    "\xc5\xd1\x21\x15\x32\x26\x92\x19\x5f\x02\x3e\x6c\x00\x00\x00\x00"
  end

  let(:rsa_md5) { 7 }

  describe '#assign' do
    let(:logon_info) do
      validation_info = Rex::Proto::Kerberos::Pac::Krb5ValidationInfo.new
      validation_info.logon_time = Time.at(1418712492)
      validation_info.effective_name = 'juan'
      validation_info.user_id = 1000
      validation_info.primary_group_id = 513
      validation_info.group_ids = [513, 512, 520, 518, 519]
      validation_info.logon_domain_name = 'DEMO.LOCAL'
      validation_info.logon_domain_id = 'S-1-5-21-1755879683-3641577184-3486455962'
      validation_info.full_name = ''
      validation_info.logon_script = ''
      validation_info.profile_path = ''
      validation_info.home_directory = ''
      validation_info.home_directory_drive = ''
      validation_info.logon_server = ''
      Rex::Proto::Kerberos::Pac::Krb5LogonInformation.new(
        data: validation_info
      )
    end

    let(:client_info) do
      Rex::Proto::Kerberos::Pac::Krb5ClientInfo.new(
        client_id: Time.at(1418712492),
        name: 'juan'
      )
    end

    let(:server_checksum) do
      Rex::Proto::Kerberos::Pac::Krb5PacServerChecksum.new(
        signature_type: rsa_md5
      )
    end

    let(:priv_srv_checksum) do
      Rex::Proto::Kerberos::Pac::Krb5PacPrivServerChecksum.new(
        signature_type: rsa_md5
      )
    end

    let(:pac_elements) do
      [
        logon_info,
        client_info,
        server_checksum,
        priv_srv_checksum
      ]
    end

    it 'creates a valid pac structure' do
      pac.assign(pac_elements: pac_elements)
      pac.sign!
      expect(pac).to eq(described_class.read(sample))
    end

    it 'the binary is equivalent' do
      pac.assign(pac_elements: pac_elements)
      pac.sign!
      expect(pac.to_binary_s).to eq(sample)
    end
  end

  describe '#read' do
    it 'correctly parses the binary data' do
      pac = described_class.read(sample)
      expect(pac.to_binary_s).to eq(sample)
    end
  end
end

RSpec.describe Rex::Proto::Kerberos::Pac::Krb5LogonInformation do
  subject(:logon_info) do
    described_class.new
  end

  let(:sample) do
    "\x01\x10\x08\x00\xcc\xcc\xcc\xcc\xa0\x01\x00\x00\x00\x00\x00\x00" \
    "\x01\x00\x00\x00\x00\x1e\x7c\x42\xfc\x18\xd0\x01\xff\xff\xff\xff" \
    "\xff\xff\xff\x7f\xff\xff\xff\xff\xff\xff\xff\x7f\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\xff\xff" \
    "\xff\xff\xff\x7f\x08\x00\x08\x00\x02\x00\x00\x00\x00\x00\x00\x00" \
    "\x03\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00" \
    "\x05\x00\x00\x00\x00\x00\x00\x00\x06\x00\x00\x00\x00\x00\x00\x00" \
    "\x07\x00\x00\x00\x00\x00\x00\x00\xe8\x03\x00\x00\x01\x02\x00\x00" \
    "\x05\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x09\x00\x00\x00\x14\x00\x14\x00\x0a\x00\x00\x00\x0b\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x10\x02\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00" \
    "\x00\x00\x00\x00\x04\x00\x00\x00\x6a\x00\x75\x00\x61\x00\x6e\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05\x00\x00\x00" \
    "\x01\x02\x00\x00\x07\x00\x00\x00\x00\x02\x00\x00\x07\x00\x00\x00" \
    "\x08\x02\x00\x00\x07\x00\x00\x00\x06\x02\x00\x00\x07\x00\x00\x00" \
    "\x07\x02\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" \
    "\x00\x00\x00\x00\x0a\x00\x00\x00\x00\x00\x00\x00\x0a\x00\x00\x00" \
    "\x44\x00\x45\x00\x4d\x00\x4f\x00\x2e\x00\x4c\x00\x4f\x00\x43\x00" \
    "\x41\x00\x4c\x00\x04\x00\x00\x00\x01\x04\x00\x00\x00\x00\x00\x05" \
    "\x15\x00\x00\x00\x03\x99\xa8\x68\xe0\x0e\x0e\xd9\x9a\x18\xcf\xcf"
  end

  describe '#read' do
    it 'correctly parses the binary data' do
      valid_info = described_class.read(sample)
      expect(valid_info.to_binary_s).to eq(sample)
    end
  end

  it 'creates a valid logon info structure' do
    valid_info = Rex::Proto::Kerberos::Pac::Krb5ValidationInfo.new
    valid_info.logon_time = Time.at(1418712492)
    valid_info.effective_name = 'juan'
    valid_info.user_id = 1000
    valid_info.primary_group_id = 513
    valid_info.group_ids = [513, 512, 520, 518, 519]
    valid_info.logon_domain_name = 'DEMO.LOCAL'
    valid_info.logon_domain_id = 'S-1-5-21-1755879683-3641577184-3486455962'
    valid_info.full_name = ''
    valid_info.logon_script = ''
    valid_info.profile_path = ''
    valid_info.home_directory = ''
    valid_info.home_directory_drive = ''
    valid_info.logon_server = ''

    logon_info.data = valid_info

    read_logon_info = described_class.read(sample)
    expect(logon_info).to eq(read_logon_info)
  end
end

RSpec.describe Rex::Proto::Kerberos::Pac::Krb5ClientInfo do
  subject(:client_info) do
    described_class.new
  end

  let(:sample) do
    "\x80\x60\x06\x1b\xbe\x18\xd0\x01\x08\x00\x6a\x00\x75\x00\x61\x00\x6e\x00"
  end

  describe '#read' do
    it 'correctly parses the binary data' do
      client_info = described_class.read(sample)
      expect(client_info.to_binary_s).to eq(sample)
    end
  end

  it 'creates a valid client info structure' do
    client_info.client_id = Time.new(2014, 12, 15, 23, 23, 17, '+00:00')
    client_info.name = 'juan'

    parsed_client_info = described_class.read(sample)
    expect(client_info).to eq(parsed_client_info)
  end
end
