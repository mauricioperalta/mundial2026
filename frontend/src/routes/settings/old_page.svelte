<script lang="ts">
	import { auth } from '$lib/auth.svelte';
	import { goto } from '$app/navigation';
	import Avatar from '$lib/components/Avatar.svelte';

	const MAX_AVATAR_BYTES = 5 * 1024 * 1024; // Límite por defecto de PocketBase para avatares

	let name = $state(auth.user?.name ?? '');
	let avatarFile = $state<File | null>(null);
	let previewUrl = $state<string | null>(null);
	let error = $state('');
	let saved = $state(false);
	let busy = $state(false);
	let fileInput: HTMLInputElement;

	let resetBusy = $state(false);
	let resetSent = $state(false);
	let resetError = $state('');

	async function sendReset() {
		if (!auth.user?.email) return;
		resetError = '';
		resetSent = false;
		resetBusy = true;
		try {
			await auth.requestPasswordReset(auth.user.email);
			resetSent = true;
		} catch (err: unknown) {
			resetError =
				(err as { message?: string })?.message ??
				'No se pudo enviar el correo de restablecimiento.';
		} finally {
			resetBusy = false;
		}
	}

	// Revocar la URL del objeto cuando se reemplace o el componente se desmonte.
	$effect(() => {
		const url = previewUrl;
		return () => {
			if (url) URL.revokeObjectURL(url);
		};
	});

	function pickFile(e: Event) {
		const target = e.target as HTMLInputElement;
		const file = target.files?.[0];
		if (!file) return;

		if (file.size > MAX_AVATAR_BYTES) {
			error = 'La imagen debe ser menor a 5MB.';
			return;
		}

		error = '';
		saved = false;
		avatarFile = file;
		if (previewUrl) URL.revokeObjectURL(previewUrl);
		previewUrl = URL.createObjectURL(file);
	}

	async function submit(e: Event) {
		e.preventDefault();
		if (busy) return;
		error = '';
		saved = false;
		busy = true;

		try {
			await auth.updateProfile(name.trim(), avatarFile);
			saved = true;
			avatarFile = null;
			if (previewUrl) {
				URL.revokeObjectURL(previewUrl);
				previewUrl = null;
			}
		} catch (err: unknown) {
			error = (err as { message?: string })?.message ?? 'Error al guardar los cambios.';
		} finally {
			busy = false;
		}
	}
</script>

<div class="settings">
	<h1>Configuración</h1>

	<form class="card" onsubmit={submit}>
		<div class="avatar-row">
			<div class="avatar-wrapper">
				<Avatar
					name={auth.user?.name ?? '?'}
					src={previewUrl ?? auth.user?.avatarUrl}
					size={80}
				/>
				<button
					type="button"
					class="btn-avatar-edit"
					onclick={() => fileInput.click()}
					disabled={busy}
					aria-label="Cambiar foto de perfil"
				>
					Cambiar
				</button>
				<input
					type="file"
					accept="image/png,image/jpeg,image/webp,image/gif"
					class="hidden-file-input"
					bind:this={fileInput}
					onchange={pickFile}
				/>
			</div>
			<div class="account-meta">
				<span class="username">@{auth.user?.username}</span>
				<span class="email muted">{auth.user?.email}</span>
			</div>
		</div>

		<div class="field">
			<label for="dn">Nombre de pantalla</label>
			<input
				id="dn"
				class="input"
				bind:value={name}
				maxlength="48"
				autocomplete="name"
				required
			/>
		</div>

		{#if error}<p class="error">{error}</p>{/if}
		{#if saved}<p class="ok">Cambios guardados.</p>{/if}

		<button class="btn" disabled={busy}>{busy ? 'Guardando…' : 'Guardar cambios'}</button>
	</form>

	<section class="card">
		<h3>Contraseña</h3>
		<p class="muted small">
			Enviaremos un enlace de restablecimiento a <strong>{auth.user?.email ?? ''}</strong>.
			Hacé clic en el enlace para elegir una nueva contraseña.
		</p>
		{#if resetError}<p class="error">{resetError}</p>{/if}
		{#if resetSent}
			<p class="ok">Correo enviado — revisá tu bandeja de entrada.</p>
		{/if}
		<button
			ttype="button"
			class="btn secondary"
			onclick={sendReset}
			disabled={resetBusy || resetSent}
		>
			{resetBusy ? 'Enviando…' : resetSent ? 'Enviado' : 'Enviar enlace de restablecimiento'}
		</button>
	</section>

	<p class="muted switch"><a href="/">Volver</a></p>
</div>

<style>
	/* El CSS se mantiene 100% idéntico */
	.settings {
		max-width: 380px;
		margin: 8dvh auto 0;
	}
	h1 {
		margin: 0;
		font-size: 1.8rem;
		font-family: var(--font-display);
		text-transform: uppercase;
		text-align: center;
	}
	h3 {
		margin: 0 0 0.5rem;
		font-family: var(--font-display);
		text-transform: uppercase;
		font-size: 1rem;
	}
	.card {
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 1.5rem;
		margin-top: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 1.25rem;
		box-shadow: var(--shadow-sm);
	}
	.avatar-row {
		display: flex;
		align-items: center;
		gap: 1.25rem;
	}
	.avatar-wrapper {
		position: relative;
		display: inline-block;
		width: 80px;
		height: 80px;
	}
	.btn-avatar-edit {
		position: absolute;
		inset: 0;
		background: rgba(0, 0, 0, 0.65);
		color: #ffffff;
		border: none;
		border-radius: 50%;
		font-size: 0.75rem;
		font-weight: 700;
		text-transform: uppercase;
		cursor: pointer;
		opacity: 0;
		transition: opacity 0.15s ease;
		display: grid;
		place-items: center;
	}
	.avatar-wrapper:hover .btn-avatar-edit {
		opacity: 1;
	}
	.hidden-file-input {
		display: none;
	}
	.account-meta {
		display: flex;
		flex-direction: column;
		gap: 2px;
		min-width: 0;
	}
	.username {
		font-weight: 700;
		font-size: 1.1rem;
	}
	.email {
		font-size: 0.85rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}
	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}
	label {
		font-size: 0.75rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--muted);
	}
	.input {
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		padding: 0.55rem 0.75rem;
		color: var(--text);
		font-size: 0.95rem;
		width: 100%;
		transition: border-color 0.15s ease;
	}
	.input:focus {
		outline: none;
		border-color: var(--accent);
	}
	.error {
		margin: 0;
		background: var(--danger-subtle, #fde8e8);
		color: var(--danger, #e02424);
		border: 1px solid var(--danger-border, #f8b4b4);
		padding: 0.55rem 0.75rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
	}
	.ok {
		margin: 0;
		background: rgba(22, 163, 74, 0.1);
		color: #16a34a;
		border: 1px solid rgba(22, 163, 74, 0.2);
		padding: 0.55rem 0.75rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
	}
	.switch {
		text-align: center;
		margin-top: 1.5rem;
		font-size: 0.9rem;
		font-weight: 600;
		text-decoration: underline;
	}
</style>
