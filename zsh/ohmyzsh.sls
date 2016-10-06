{% for name, user in salt['pillar.get']('users', {}).iteritems()
     if 'ohmyzsh' in user and user.ohmyzsh %}

{% set current = salt['user.info'](name) %}
{% set home = user.get('home', current.get('home', "/home/%s" % name)) %}

clone_ohmyzsh_{{ name }}:
  git.latest:
    - name: git://github.com/robbyrussell/oh-my-zsh.git
    - target: {{ home }}/.oh-my-zsh
{% if name != "root" %}
    - require:
      - user: users_{{ name }}_user
{%   set nonroot = True %}
{% endif %}

{% if 'manage_zshrc' not in user or not user.manage_zshrc %}
copy_ohmyzsh_defaultzshrc_{{ name }}:
  file.copy:
    - name: {{ home }}/.zshrc
    - source:  {{ home }}/.oh-my-zsh/templates/zshrc.zsh-template
    - require:
      - git: clone_ohmyzsh_{{ name }}
{% endif%}

{% endfor %}

{% if nonroot is defined and nonroot %}
include:
  - users
{% endif %}
