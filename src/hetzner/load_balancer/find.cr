require "../client"
require "../load_balancer"
require "../load_balancers_list"

class Hetzner::LoadBalancer::Find
  getter hetzner_client : Hetzner::Client
  getter load_balancer_name : String

  def initialize(@hetzner_client, @load_balancer_name)
  end

  def run
    load_balancers = LoadBalancersList.from_json(hetzner_client.get("/load_balancers")).load_balancers

    load_balancers.find do |load_balancer|
      load_balancer.name == load_balancer_name
    end
  end
end
