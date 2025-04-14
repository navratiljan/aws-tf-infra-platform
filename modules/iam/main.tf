resource "aws_iam_role" "role" {
    name = var.iam_role_name
    assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
    for_each = toset(var.policy_attachments)

    role = aws_iam_role.role.name
    policy_arn = each.key
}

resource "aws_iam_policy" "custom_policy" {
    for_each = var.custom_policies 
    name = each.key
    policy = each.value
}

resource "aws_iam_role_policy_attachment" "policy_attachment_custom" {
    for_each = aws_iam_policy.custom_policy
    role = aws_iam_role.role.name
    policy_arn = aws_iam_policy.custom_policy[each.key].arn
}
