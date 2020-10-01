class NewListSet < BlacklightOaiProvider::SolrSet
  def description
    "This is a #{label} set containing records with the value of #{value}."
  end
end
