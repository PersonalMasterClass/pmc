module ApplicationHelper

  def edit_presenter_profile_link(presenter, class_name = '')
    link_to "Edit Profile",  new_presenter_profile_path(presenter), 'data-no-turbolink' => true, class: class_name
  end
end
