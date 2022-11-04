MESSAGE_PART_ONE = "<span class=\"atwho-inserted\" data-atwho-at-query=\"@\" contenteditable=\"false\"><a href="
MESSAGE_PART_TWO = "</a></span>&nbsp;has placed a bet for $50 against <span class=\"atwho-inserted\" data-atwho-at-query=\"@\" contenteditable=\"false\"><a href="
MESSAGE_PART_THREE = "</a></span>&nbsp;"


def create_bet_message_string(user_one, user_two)
    return MESSAGE_PART_ONE + "\"/users/" + user_one.id.to_s + "\">" + user_one.name + MESSAGE_PART_TWO + "\"/users/" + user_two.id.to_s + "\">" + user_two.name + MESSAGE_PART_THREE
end



"<span class=\"atwho-inserted\" data-atwho-at-query=\"@\" contenteditable=\"false\"><a href=\"/users/1\">Cheryle Kessler</a></span>&nbsp;eats good food with <span class=\"atwho-inserted\" data-atwho-at-query=\"@\" contenteditable=\"false\"><a href=\"/users/2\">Tiesha Nikolaus</a></span>&nbsp;"