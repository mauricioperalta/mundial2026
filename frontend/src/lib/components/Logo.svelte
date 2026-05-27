<script lang="ts">
	let { compact = false }: { compact?: boolean } = $props();
</script>

<a class="logo" href="/" aria-label="AudiRed Mundial home">
	<img class="mark" src="https://audired.com.ar/logos/principal2.png" alt="AudiRed logo" />
	{#if !compact}<span class="word">Mundial&nbsp;2026</span>{/if}
</a>

<style>
	.logo {
		display: inline-flex;
		align-items: center;
		gap: 0.75rem;
		color: var(--text);
		font-weight: 800;
		letter-spacing: -0.02em;
	}
	.mark {
		height: 36px;
		width: auto;
		display: block;
	}
	.word {
		font-family: var(--font-display);
		font-size: 1.25rem;
		letter-spacing: 0.01em;
		text-transform: uppercase;
	}
</style>
