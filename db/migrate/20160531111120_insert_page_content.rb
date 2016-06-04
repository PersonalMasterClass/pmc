class InsertPageContent < ActiveRecord::Migration
  def change
    PageContent.create(name: "aboutPMC",          content: "TODO: Update Content", url: "/aboutus")
    PageContent.create(name: "contact",           content: "TODO: Update Content", url: "/contactus")
    PageContent.create(name: "dmca",              content: "TODO: Update Content", url: "/dmca")
    PageContent.create(name: "earnings",          content: "TODO: Update Content", url: "/earningsnotice")
    PageContent.create(name: "privacy",           content: "TODO: Update Content", url: "/privacypolicy")
    PageContent.create(name: "terms",             content: "TODO: Update Content", url: "/termsofuse")
    PageContent.create(name: "profile-help",      content: "TODO: Update Content", url: "/")
  end
end
