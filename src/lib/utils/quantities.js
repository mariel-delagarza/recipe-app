
const UNICODE_FRACTIONS = {
	'½': '1/2',
	'⅓': '1/3',
	'⅔': '2/3',
	'¼': '1/4',
	'¾': '3/4',
	'⅛': '1/8',
	'⅜': '3/8',
	'⅝': '5/8',
	'⅞': '7/8'
};

const DENOMINATORS = [2, 3, 4, 6, 8, 12, 16];

/**
 * Convert a cookbook quantity to a number.
 * Returns null for empty or invalid input.
 *
 * Examples:
 * '1/3'   -> 0.333
 * '1 1/2' -> 1.5
 * '2¾'    -> 2.75
 */
export function parseQuantity(input) {
	if (input == null || String(input).trim() === '') {
		return null;
	}

	let value = String(input).trim();

	// Normalize Unicode fractions, including mixed numbers like 2¾.
	for (const [symbol, fraction] of Object.entries(UNICODE_FRACTIONS)) {
		value = value.replaceAll(symbol, ` ${fraction}`);
	}

	value = value.replace(/\s+/g, ' ').trim();

	let result;

	// Mixed number: 1 1/2
	const mixed = value.match(/^(\d+)\s+(\d+)\/(\d+)$/);

	// Simple fraction: 1/2
	const fraction = value.match(/^(\d+)\/(\d+)$/);

	// Whole number or decimal: 2, 0.5
	const decimal = value.match(/^\d+(?:\.\d+)?$/);

	if (mixed) {
		const [, whole, numerator, denominator] = mixed.map(Number);
		if (denominator === 0 || numerator >= denominator) return null;
		result = whole + numerator / denominator;
	} else if (fraction) {
		const numerator = Number(fraction[1]);
		const denominator = Number(fraction[2]);
		if (denominator === 0) return null;
		result = numerator / denominator;
	} else if (decimal) {
		result = Number(value);
	} else {
		return null;
	}

	if (!Number.isFinite(result) || result <= 0) return null;

	// Store numeric quantities at three-decimal precision.
	return Math.round((result + Number.EPSILON) * 1000) / 1000;
}

/**
 * Format a numeric quantity using common cookbook fractions.
 * Intended as a fallback for older recipes.
 */
export function formatQuantity(quantity) {
	if (quantity == null || quantity === '') return '';

	const value = Number(quantity);
	if (!Number.isFinite(value) || value <= 0) return '';

	const whole = Math.floor(value);
	const remainder = value - whole;

	if (remainder < 0.0005) return String(whole);

	let best = null;
	let bestError = Infinity;

	for (const denominator of DENOMINATORS) {
		const numerator = Math.round(remainder * denominator);

		if (numerator === 0 || numerator >= denominator) continue;

		const error = Math.abs(remainder - numerator / denominator);

		if (error < bestError) {
			bestError = error;
			best = { numerator, denominator };
		}
	}

	// Avoid inventing a misleading fraction for unusual values.
	if (!best || bestError > 0.005) {
		return String(value);
	}

	// Reduce fractions, e.g. 2/4 -> 1/2.
	const gcd = (a, b) => (b === 0 ? a : gcd(b, a % b));
	const divisor = gcd(best.numerator, best.denominator);

	const numerator = best.numerator / divisor;
	const denominator = best.denominator / divisor;

	return whole > 0
		? `${whole} ${numerator}/${denominator}`
		: `${numerator}/${denominator}`;
}

/**
 * Return the preferred display quantity.
 * New recipes preserve the original input.
 * Older recipes fall back to fraction formatting.
 */
export function displayQuantity(quantity, quantityDisplay) {
	if (quantityDisplay != null && String(quantityDisplay).trim() !== '') {
		return String(quantityDisplay).trim();
	}

	return formatQuantity(quantity);
}
