MESSAGE_PART_ONE = "<span class=\"atwho-inserted\" data-atwho-at-query=\"@\" contenteditable=\"false\"><a href="
MESSAGE_PART_TWO = "</a></span>&nbsp;has placed a bet for $"
MESSAGE_PART_TWO_CANCEL = "</a></span>&nbsp;has cancelled a bet for $"
MESSAGE_PART_THREE = " against <span class=\"atwho-inserted\" data-atwho-at-query=\"@\" contenteditable=\"false\"><a href="
MESSAGE_PART_FOUR = "</a></span>&nbsp;"


def create_bet_message_string(user_one, user_two, bet)
    return MESSAGE_PART_ONE + "\"/users/" + user_one.id.to_s + "\">" + user_one.name + MESSAGE_PART_TWO + bet.amount.to_s + MESSAGE_PART_THREE + "\"/users/" + user_two.id.to_s + "\">" + user_two.name + MESSAGE_PART_FOUR
end

def create_bet_cancel_message_string(user_one, user_two, bet)
    return MESSAGE_PART_ONE + "\"/users/" + user_one.id.to_s + "\">" + user_one.name + MESSAGE_PART_TWO_CANCEL + bet.amount.to_s + MESSAGE_PART_THREE + "\"/users/" + user_two.id.to_s + "\">" + user_two.name + MESSAGE_PART_FOUR
end



