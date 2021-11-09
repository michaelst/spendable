import React from 'react'
import {
  Image,
  Text,
  TouchableHighlight,
  View
} from 'react-native'
import { useNavigation } from '@react-navigation/native'
import { useQuery } from '@apollo/client'
import useAppStyles from 'src/utils/useAppStyles'
import { PlaidLink } from 'react-native-plaid-link-sdk'
import { ListBankMembers_bankMembers } from 'src/graphql/ListBankMembers'
import { GetBankMemberPlaidLinkToken } from 'src/graphql/GetBankMemberPlaidLinkToken'
import { GET_BANK_MEMBER_PLAID_LINK_TOKEN } from 'src/queries'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faChevronRight, faExclamationCircle } from '@fortawesome/free-solid-svg-icons'

type Props = {
  bankMember: ListBankMembers_bankMembers,
}

const BankMemberRow = ({ bankMember }: Props) => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, fontSize, colors, baseUnit } = useAppStyles()

  const { data: plaidData } = useQuery<GetBankMemberPlaidLinkToken>(GET_BANK_MEMBER_PLAID_LINK_TOKEN, {
    variables: { id: bankMember.id },
    fetchPolicy: 'no-cache'
  })

  const navigateToBank = () => navigation.navigate('Bank', { bankMemberId: bankMember.id })

  return (
    <TouchableHighlight onPress={navigateToBank}>
      <View style={styles.row}>
        {bankMember.logo && (
          <Image
            source={{ uri: `data:image/png;base64,${bankMember.logo}` }}
            style={{
              width: 36,
              height: 36,
              marginRight: baseUnit
            }}
          />
        )}
        <View style={{ flex: 1 }}>
          <Text style={styles.text}>
            {bankMember.name}
          </Text>
        </View>

        <View style={{ flexDirection: "row" }}>
          {bankMember.status != "CONNECTED" && plaidData && (
            <PlaidLink
              tokenConfig={{ token: plaidData.bankMember.plaidLinkToken, }}
              onSuccess={success => console.log(success)}
            >
              <FontAwesomeIcon
                icon={faExclamationCircle}
                size={fontSize}
                color='red'
                style={{
                  marginRight: baseUnit
                }}
              />
            </PlaidLink>
          )}
          <FontAwesomeIcon icon={faChevronRight} size={fontSize} color={colors.secondary} />
        </View>
      </View>
    </TouchableHighlight>
  )
}

export default BankMemberRow