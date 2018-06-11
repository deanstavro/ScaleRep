desc "This task is called by the Heroku scheduler add-on"
task :add_contacts_to_reply [:all_hash, :campaign]=> :environment do |task, args|
  AddContactsToReplyJob.perform_now(args.all_hash, args.campaign)
end
