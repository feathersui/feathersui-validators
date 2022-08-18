/*
	Licensed to the Apache Software Foundation (ASF) under one or more
	contributor license agreements.  See the NOTICE file distributed with
	this work for additional information regarding copyright ownership.
	The ASF licenses this file to You under the Apache License, Version 2.0
	(the "License"); you may not use this file except in compliance with
	the License.  You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
 */

package feathers.validators;

/**
	The CreditCardValidatorCardType class defines value constants
	for specifying the type of credit card to validate.
	These values are used in the `CreditCardValidator.cardType`
	property.

	@see `feathers.validators.CreditCardValidator`
**/
final class CreditCardValidatorCardType {
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
		Specifies the card type as MasterCard.
	**/
	public static final MASTER_CARD:String = "MasterCard";

	/**
		Specifies the card type as Visa.
	**/
	public static final VISA:String = "Visa";

	/**
		Specifies the card type as American Express.
	**/
	public static final AMERICAN_EXPRESS:String = "American Express";

	/**
		Specifies the card type as Discover.
	**/
	public static final DISCOVER:String = "Discover";

	/**
		Specifies the card type as Diners Club.
	**/
	public static final DINERS_CLUB:String = "Diners Club";
}
