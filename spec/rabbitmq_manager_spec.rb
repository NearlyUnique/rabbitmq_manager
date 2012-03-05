require './lib/rabbitmq_manager'

describe RabbitMQManager do
  let(:manager) { 
    RabbitMQManager.new 'http://guest:guest@localhost:55672' 
  }

  context '#overview' do
    subject { manager.overview }
    it { should be_instance_of Hash }
  end

  context '#nodes' do 
    subject { manager.nodes }
    it { should have(1).things }
  end

  context '#node' do
    let(:hostname) { `hostname -s`.chop }
    subject { manager.node("rabbit@#{hostname}") }
    it { should be_instance_of Hash }
  end

  context 'when administering users and vhosts' do
    let(:user)  { 'user1' }
    let(:passwd)  { 'rand123' }
    let(:vhost) { 'vh1' }

    before do
      manager.user_create user, passwd
      manager.vhost_create vhost
    end

    after do
      manager.user_delete user
      manager.vhost_delete vhost
    end
    
    it 'can list vhosts' do
      manager.vhosts.should have_at_least(2).things
    end

    it 'can view one vhost' do 
      manager.vhost(vhost)['name'].should == vhost
    end

    it 'can list users' do 
      manager.users.should have_at_least(2).things
    end

    it 'can view one user' do 
      manager.user(user)['name'].should == user
    end

    it 'cannot view an non existing user' do
      lambda {
        manager.user('foo')
      }.should raise_error Faraday::Error::ResourceNotFound
    end

    it 'can set permissions' do 
      manager.user_set_permissions(user, vhost, '.*', '.*', '.*')
      manager.user_permissions(user).should == [{
        "user"=>"user1",
        "vhost"=>"vh1",
        "configure"=>".*",
        "write"=>".*",
        "read"=>".*"
      }]
    end
  end
end